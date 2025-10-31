import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import '../utils/price_calculator.dart';

/// 周期选择器
class PeriodSelector extends StatelessWidget {
  final List<Map<String, dynamic>> periods;
  final String? selectedPeriod;
  final Function(String) onPeriodSelected;
  final int? couponType;
  final int? couponValue;

  const PeriodSelector({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    this.couponType,
    this.couponValue,
  });

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context).xboardSelectPaymentPeriod,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        if (periods.length <= 2)
          _buildRowLayout()
        else
          _buildGridLayout(context),
      ],
    );
  }

  Widget _buildRowLayout() {
    return Row(
      children: periods.map((period) {
        final isSelected = selectedPeriod == period['period'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _PeriodCard(
              period: period,
              isSelected: isSelected,
              onTap: () => onPeriodSelected(period['period']),
              couponType: couponType,
              couponValue: couponValue,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index];
        final isSelected = selectedPeriod == period['period'];
        return _PeriodCard(
          period: period,
          isSelected: isSelected,
          onTap: () => onPeriodSelected(period['period']),
          couponType: couponType,
          couponValue: couponValue,
        );
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final Map<String, dynamic> period;
  final bool isSelected;
  final VoidCallback onTap;
  final int? couponType;
  final int? couponValue;

  const _PeriodCard({
    required this.period,
    required this.isSelected,
    required this.onTap,
    this.couponType,
    this.couponValue,
  });

  @override
  Widget build(BuildContext context) {
    final periodPrice = period['price']?.toDouble() ?? 0.0;
    final displayPrice = isSelected && couponType != null
        ? PriceCalculator.calculateFinalPrice(
            periodPrice,
            couponType,
            couponValue,
          )
        : periodPrice;

    final hasDiscount = isSelected && 
        couponType != null && 
        displayPrice < periodPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    period['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (hasDiscount) ...[
              Text(
                PriceCalculator.formatPrice(periodPrice),
                style: TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.white70,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                PriceCalculator.formatPrice(displayPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else
              Text(
                PriceCalculator.formatPrice(periodPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.blue.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

