import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';
import '../bloc/room_management_bloc.dart';
import '../bloc/room_management_event.dart';
import '../bloc/room_management_state.dart';

class RoomManagementPage extends StatelessWidget {
  const RoomManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RoomManagementBloc>()
        ..add(const LoadRoomsRequested()),
      child: const _RoomManagementView(),
    );
  }
}

class _RoomManagementView extends StatefulWidget {
  const _RoomManagementView();

  @override
  State<_RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<_RoomManagementView> {
  RoomType? _filterRoomType;
  bool? _filterIsActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Salas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _filterIsActive = null;
                  _filterRoomType = null;
                } else if (value == 'active') {
                  _filterIsActive = true;
                } else if (value == 'inactive') {
                  _filterIsActive = false;
                } else {
                  _filterRoomType = RoomType.values.firstWhere((t) => t.value == value);
                }
              });
              context.read<RoomManagementBloc>().add(
                    LoadRoomsRequested(
                      isActive: _filterIsActive,
                      roomType: _filterRoomType,
                    ),
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Todas')),
              const PopupMenuItem(value: 'active', child: Text('Ativas')),
              const PopupMenuItem(value: 'inactive', child: Text('Inativas')),
              const PopupMenuDivider(),
              ...RoomType.values.map(
                (type) => PopupMenuItem(value: type.value, child: Text(type.label)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RoomManagementBloc>().add(const RefreshRoomsRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<RoomManagementBloc, RoomManagementState>(
        listener: (context, state) {
          state.whenOrNull(
            saved: (room) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sala salva com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<RoomManagementBloc>().add(
                    LoadRoomsRequested(
                      isActive: _filterIsActive,
                      roomType: _filterRoomType,
                    ),
                  );
            },
            deleted: (roomId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sala excluída com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<RoomManagementBloc>().add(
                    LoadRoomsRequested(
                      isActive: _filterIsActive,
                      roomType: _filterRoomType,
                    ),
                  );
            },
            error: (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.userMessage),
                  backgroundColor: failure.isCritical ? AppColors.error : AppColors.alertWarning,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Carregando salas...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (rooms) => _buildRoomsList(context, rooms),
            saving: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Salvando sala...'),
                ],
              ),
            ),
            saved: (room) => const Center(child: CircularProgressIndicator()),
            deleting: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Excluindo sala...'),
                ],
              ),
            ),
            deleted: (roomId) => const Center(child: CircularProgressIndicator()),
            error: (failure) => _buildErrorView(context, failure.userMessage),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoomDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Sala'),
      ),
    );
  }

  Widget _buildRoomsList(BuildContext context, List<Room> rooms) {
    if (rooms.isEmpty) {
      return const Center(
        child: Text('Nenhuma sala encontrada'),
      );
    }

    return ListView.builder(
      itemCount: rooms.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _buildRoomCard(context, room);
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getRoomTypeColor(room.roomType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.event_seat, color: Colors.white, size: 32),
        ),
        title: Text(
          room.name,
          style: AppTextStyles.h3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tipo: ${room.roomType.label}'),
            Text('Capacidade: ${room.capacity} assentos'),
            if (room.sessionsCount != null)
              Text('${room.sessionsCount} sessões agendadas'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: room.isActive ? AppColors.success : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                room.isActive ? 'Ativa' : 'Inativa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditRoomDialog(context, room);
                break;
              case 'toggle_status':
                if (room.isActive) {
                  _deactivateRoom(context, room);
                } else {
                  _activateRoom(context, room);
                }
                break;
              case 'delete':
                _showDeleteConfirmation(context, room);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    room.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(room.isActive ? 'Desativar' : 'Ativar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomTypeColor(RoomType roomType) {
    switch (roomType) {
      case RoomType.twoD:
        return Colors.blue;
      case RoomType.threeD:
        return Colors.purple;
      case RoomType.imax:
        return Colors.orange;
      case RoomType.extreme:
        return Colors.red;
      case RoomType.vip:
        return AppColors.goldenReel;
    }
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<RoomManagementBloc>().add(
                      LoadRoomsRequested(
                        isActive: _filterIsActive,
                        roomType: _filterRoomType,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    _showRoomFormDialog(context, null);
  }

  void _showEditRoomDialog(BuildContext context, Room room) {
    _showRoomFormDialog(context, room);
  }

  void _showRoomFormDialog(BuildContext context, Room? room) {
    final isEditing = room != null;
    final nameController = TextEditingController(text: room?.name);
    final capacityController = TextEditingController(text: room?.capacity.toString());
    RoomType selectedRoomType = room?.roomType ?? RoomType.twoD;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Sala' : 'Nova Sala'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Sala *',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Sala 1, Sala VIP',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidade *',
                      border: OutlineInputBorder(),
                      hintText: 'Número de assentos',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RoomType>(
                    value: selectedRoomType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Sala *',
                      border: OutlineInputBorder(),
                    ),
                    items: RoomType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRoomType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || capacityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos obrigatórios'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final capacity = int.tryParse(capacityController.text);
                if (capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Capacidade deve ser um número positivo'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  final params = UpdateRoomParams(
                    roomId: room.id,
                    name: nameController.text,
                    capacity: capacity,
                    roomType: selectedRoomType,
                  );
                  context.read<RoomManagementBloc>().add(UpdateRoomRequested(params: params));
                } else {
                  final params = CreateRoomParams(
                    name: nameController.text,
                    capacity: capacity,
                    roomType: selectedRoomType,
                  );
                  context.read<RoomManagementBloc>().add(CreateRoomRequested(params: params));
                }

                Navigator.of(dialogContext).pop();
              },
              child: Text(isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _activateRoom(BuildContext context, Room room) {
    context.read<RoomManagementBloc>().add(ActivateRoomRequested(roomId: room.id));
  }

  void _deactivateRoom(BuildContext context, Room room) {
    final params = UpdateRoomParams(roomId: room.id, isActive: false);
    context.read<RoomManagementBloc>().add(UpdateRoomRequested(params: params));
  }

  void _showDeleteConfirmation(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja realmente excluir a sala "${room.name}"?'),
            if (room.sessionsCount != null && room.sessionsCount! > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.alertWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.alertWarning),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atenção:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Esta sala possui ${room.sessionsCount} sessões agendadas. A exclusão será apenas lógica (desativação).',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final hasActiveSessions = room.sessionsCount != null && room.sessionsCount! > 0;
              context.read<RoomManagementBloc>().add(
                    DeleteRoomRequested(
                      roomId: room.id,
                      permanent: !hasActiveSessions,
                    ),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
