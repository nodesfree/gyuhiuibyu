import 'package:fl_clash/xboard/features/online_support/providers/chat_provider.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 移动端底部导航栏
class MobileNavigationBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const MobileNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        const NavigationDestination(
          icon: Icon(Icons.shopping_cart),
          label: '套餐',
        ),
        NavigationDestination(
          icon: _buildIconWithBadge(
            const Icon(Icons.support_agent),
            chatState.unreadCount,
          ),
          label: '客服',
        ),
        const NavigationDestination(
          icon: Icon(Icons.people),
          label: '邀请',
        ),
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }

  /// 带未读标记的图标
  Widget _buildIconWithBadge(Widget icon, int count) {
    if (count == 0) return icon;

    return BadgeIcon(
      icon: icon,
      count: count,
    );
  }
}

