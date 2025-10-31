import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart';
import '../utils/price_calculator.dart';

/// 套餐信息头部卡片
class PlanHeaderCard extends StatelessWidget {
  final PlanData plan;

  const PlanHeaderCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左边：大图标（占两行高度）
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // 右边：上下两行
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 第一行：套餐名字（稍大，居中）
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // 第二行：流量 + 速率（居中）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompactInfo(
                      Icons.cloud_download_outlined,
                      PriceCalculator.formatTraffic(plan.transferEnable),
                    ),
                    if ((plan.speedLimit ?? 0) > 0) ...[
                      const SizedBox(width: 10),
                      _buildCompactInfo(
                        Icons.speed,
                        '${plan.speedLimit}Mbps',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

