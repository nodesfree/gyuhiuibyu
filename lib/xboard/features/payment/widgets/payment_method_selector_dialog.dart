import 'package:fl_clash/xboard/sdk/xboard_sdk.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';

/// 支付方式选择对话框
class PaymentMethodSelectorDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;

  const PaymentMethodSelectorDialog({
    super.key,
    required this.paymentMethods,
    this.selectedMethod,
  });

  @override
  State<PaymentMethodSelectorDialog> createState() => _PaymentMethodSelectorDialogState();

  /// 显示支付方式选择对话框
  static Future<PaymentMethod?> show(
    BuildContext context, {
    required List<PaymentMethod> paymentMethods,
    PaymentMethod? selectedMethod,
  }) async {
    return await showDialog<PaymentMethod>(
      context: context,
      builder: (context) => PaymentMethodSelectorDialog(
        paymentMethods: paymentMethods,
        selectedMethod: selectedMethod,
      ),
    );
  }
}

class _PaymentMethodSelectorDialogState extends State<PaymentMethodSelectorDialog> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).xboardSelectPaymentMethod,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.paymentMethods.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final method = widget.paymentMethods[index];
            final isSelected = _selectedMethod?.id == method.id;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: method.icon != null && method.icon!.isNotEmpty
                  ? Image.network(
                      method.icon!,
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.payment, size: 32);
                      },
                    )
                  : const Icon(Icons.payment, size: 32),
              title: Text(
                method.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              subtitle: method.feePercent > 0
                  ? Text(
                      '${AppLocalizations.of(context).xboardHandlingFee}: ${method.feePercent}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                  : null,
              trailing: Radio<String>(
                value: method.id,
                groupValue: _selectedMethod?.id,
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = method;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _selectedMethod = method;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _selectedMethod == null
              ? null
              : () => Navigator.of(context).pop(_selectedMethod),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }
}
