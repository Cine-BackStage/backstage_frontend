import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/payment.dart';

/// Dialog for adding payment to sale
class PaymentDialog extends StatefulWidget {
  final double remainingAmount;
  final Function(PaymentMethod method, double amount, String? authCode)
      onAddPayment;

  const PaymentDialog({
    super.key,
    required this.remainingAmount,
    required this.onAddPayment,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _authCodeController = TextEditingController();
  
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _useFullAmount = true;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.remainingAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Adicionar Pagamento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Remaining amount display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Valor Restante',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${widget.remainingAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment method selection
              Text(
                'Método de Pagamento',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentMethod.values.map((method) {
                  final isSelected = _selectedMethod == method;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentIcon(method),
                          size: 16,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(method.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedMethod = method;
                        });
                      }
                    },
                    showCheckmark: false,
                    selectedColor: Colors.orange,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Use full amount checkbox
              CheckboxListTile(
                value: _useFullAmount,
                onChanged: (value) {
                  setState(() {
                    _useFullAmount = value ?? true;
                    if (_useFullAmount) {
                      _amountController.text =
                          widget.remainingAmount.toStringAsFixed(2);
                    }
                  });
                },
                title: const Text(
                  'Pagar valor total',
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              const SizedBox(height: 4),

              // Amount input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                enabled: !_useFullAmount,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Valor inválido';
                  }
                  if (amount > widget.remainingAmount) {
                    return 'Valor maior que o restante';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Auth code for card payments
              if (_selectedMethod == PaymentMethod.card)
                TextFormField(
                  controller: _authCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Autorização',
                    hintText: 'Opcional',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _handleAddPayment,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.attach_money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.pix:
        return Icons.qr_code;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  void _handleAddPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final authCode = _authCodeController.text.trim().isEmpty
          ? null
          : _authCodeController.text.trim();

      widget.onAddPayment(_selectedMethod, amount, authCode);
    }
  }
}
