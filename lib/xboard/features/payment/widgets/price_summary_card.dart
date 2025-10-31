import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import '../utils/price_calculator.dart';

/// 价格汇总卡片
class PriceSummaryCard extends StatelessWidget {
  final double originalPrice;
  final double? finalPrice;
  final double? discountAmount;
  final double? userBalance;

  const PriceSummaryCard({
    super.key,
    required this.originalPrice,
    this.finalPrice,
    this.discountAmount,
    this.userBalance,
  });

  @override
  Widget build(BuildContext context) {
    final displayFinalPrice = finalPrice ?? originalPrice;
    final hasDiscount = discountAmount != null && discountAmount! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        children: [
          // 账户余额（如果有）
          if (userBalance != null && userBalance! > 0) ...[
            _BalanceRow(balance: userBalance!),
            Divider(height: 24, color: Colors.blue.shade200),
          ],

          // 原价和优惠（如果有折扣）
          if (hasDiscount) ...[
            _PriceRow(
              label: '原价',
              price: originalPrice,
              isStrikethrough: true,
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: '优惠',
              price: discountAmount!,
              isDiscount: true,
            ),
            Divider(height: 24, color: Colors.blue.shade200),
          ],

          // 实付金额
          _FinalPriceRow(price: displayFinalPrice),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final double balance;

  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.blue.shade600,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context).xboardAccountBalance,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          PriceCalculator.formatPrice(balance),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final bool isStrikethrough;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.price,
    this.isStrikethrough = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          isDiscount
              ? '-${PriceCalculator.formatPrice(price)}'
              : PriceCalculator.formatPrice(price),
          style: TextStyle(
            fontSize: 14,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            fontWeight: isDiscount ? FontWeight.w600 : null,
            color: isDiscount
                ? Colors.green.shade700
                : (isStrikethrough ? Colors.grey.shade500 : null),
          ),
        ),
      ],
    );
  }
}

class _FinalPriceRow extends StatelessWidget {
  final double price;

  const _FinalPriceRow({required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '实付金额',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        Text(
          PriceCalculator.formatPrice(price),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }
}

