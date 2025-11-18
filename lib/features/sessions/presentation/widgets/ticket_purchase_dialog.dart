import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/formatters/cpf_formatter.dart';
import '../../../../shared/utils/validators/cpf_validator.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';

class TicketPurchaseDialog extends StatefulWidget {
  final String sessionId;

  const TicketPurchaseDialog({
    super.key,
    required this.sessionId,
  });

  @override
  State<TicketPurchaseDialog> createState() => _TicketPurchaseDialogState();
}

class _TicketPurchaseDialogState extends State<TicketPurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handlePurchase() {
    if (_formKey.currentState!.validate()) {
      context.read<SessionsBloc>().add(
            PurchaseTicketsRequested(
              sessionId: widget.sessionId,
              customerCpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
              customerName: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
            ),
          );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dados do Cliente'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF *',
                hintText: '000.000.000-00',
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [CpfFormatter()],
              validator: (value) => CpfValidator.validate(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome (opcional)',
                hintText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handlePurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Confirmar Compra'),
        ),
      ],
    );
  }
}
