import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';
import '../bloc/room_management_bloc.dart';
import '../bloc/room_management_event.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room; // null = create mode, not null = edit mode

  const RoomFormDialog({super.key, this.room});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late RoomType _selectedRoomType;
  bool _isActive = true;

  bool get isEditMode => widget.room != null;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _nameController = TextEditingController(text: room?.name ?? '');
    _capacityController = TextEditingController(
      text: room?.capacity.toString() ?? '',
    );
    _selectedRoomType = room?.roomType ?? RoomType.twoD;
    _isActive = room?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final capacity = int.tryParse(_capacityController.text) ?? 0;

    if (isEditMode) {
      // Update existing room
      context.read<RoomManagementBloc>().add(
        UpdateRoomRequested(
          params: UpdateRoomParams(
            roomId: widget.room!.id,
            name: _nameController.text.trim(),
            capacity: capacity,
            roomType: _selectedRoomType,
            isActive: _isActive,
          ),
        ),
      );
    } else {
      // Create new room
      context.read<RoomManagementBloc>().add(
        CreateRoomRequested(
          params: CreateRoomParams(
            name: _nameController.text.trim(),
            capacity: capacity,
            roomType: _selectedRoomType,
          ),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Color _getRoomTypeColor(RoomType roomType) {
    switch (roomType) {
      case RoomType.twoD:
        return Colors.blue;
      case RoomType.threeD:
        return Colors.purple;
      case RoomType.extreme:
        return Colors.red;
    }
  }

  IconData _getRoomTypeIcon(RoomType roomType) {
    switch (roomType) {
      case RoomType.threeD:
      case RoomType.extreme:
        return Icons.theaters;
      default:
        return Icons.meeting_room;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Editar Sala' : 'Nova Sala',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name (required)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Sala *',
                          hintText: 'Ex: Sala 1',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Capacity (required)
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacidade (assentos) *',
                          hintText: 'Ex: 150',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Capacidade é obrigatória';
                          }
                          final capacity = int.tryParse(value);
                          if (capacity == null || capacity <= 0) {
                            return 'Capacidade inválida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Room Type Selector
                      Text(
                        'Tipo de Sala *',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RoomType.values.map((type) {
                          final isSelected = _selectedRoomType == type;
                          final color = _getRoomTypeColor(type);
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getRoomTypeIcon(type),
                                  size: 16,
                                  color: isSelected ? Colors.white : color,
                                ),
                                const SizedBox(width: 6),
                                Text(type.label),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: color,
                            backgroundColor: color.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: color, width: 1.5),
                            onSelected: (selected) {
                              setState(() {
                                _selectedRoomType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Active Status (only in edit mode)
                      if (isEditMode)
                        SwitchListTile(
                          title: const Text('Sala Ativa'),
                          subtitle: Text(
                            _isActive
                                ? 'Sala visível para criação de sessões'
                                : 'Sala oculta',
                            style: AppTextStyles.bodySmall,
                          ),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(isEditMode ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
