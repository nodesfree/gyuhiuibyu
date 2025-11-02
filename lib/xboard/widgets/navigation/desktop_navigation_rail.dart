import 'package:fl_clash/xboard/features/online_support/providers/chat_provider.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/features/invite/widgets/user_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 桌面端侧边导航栏
class DesktopNavigationRail extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const DesktopNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // 导航项
          Expanded(
            child: _buildNavigationItems(context, colorScheme, chatState),
          ),
          
          // 底部功能区
          _buildBottomActions(colorScheme),
        ],
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            colorScheme.outline.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// 导航项
  Widget _buildNavigationItems(
    BuildContext context,
    ColorScheme colorScheme,
    ChatState chatState,
  ) {
    return NavigationRail(
      backgroundColor: Colors.transparent,
      selectedIndex: selectedIndex,
      extended: false,
      labelType: NavigationRailLabelType.all,
      leading: null,
      useIndicator: true,
      indicatorColor: colorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 26,
      ),
      selectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontSize: 11,
        color: colorScheme.onSurfaceVariant,
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: const Text('首页'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.shopping_bag_outlined),
          selectedIcon: const Icon(Icons.shopping_bag),
          label: const Text('套餐'),
        ),
        NavigationRailDestination(
          icon: _buildIconWithBadge(
            const Icon(Icons.support_agent_outlined),
            chatState.unreadCount,
          ),
          selectedIcon: _buildIconWithBadge(
            const Icon(Icons.support_agent),
            chatState.unreadCount,
          ),
          label: const Text('客服'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: const Text('邀请'),
        ),
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }

  /// 底部功能区
  Widget _buildBottomActions(ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDivider(colorScheme),
        const SizedBox(height: 16),
        const UserMenuWidget(),
        const SizedBox(height: 16),
      ],
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

