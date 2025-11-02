import 'package:fl_clash/xboard/features/online_support/providers/chat_provider.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// 适配性的 Shell 布局
/// 桌面端：侧边栏 + 内容区
/// 移动端：底部导航栏 + 内容区
class AdaptiveShellLayout extends ConsumerStatefulWidget {
  final Widget child;

  const AdaptiveShellLayout({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AdaptiveShellLayout> createState() => _AdaptiveShellLayoutState();
}

class _AdaptiveShellLayoutState extends ConsumerState<AdaptiveShellLayout> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location.startsWith('/plans')) return 1;
    if (location.startsWith('/support')) return 2;
    if (location.startsWith('/invite')) return 3;
    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/plans');
        break;
      case 2:
        context.go('/support');
        break;
      case 3:
        context.go('/invite');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final currentIndex = _getCurrentIndex(context);
    
    if (isDesktop) {
      // 桌面端：侧边栏 + 内容区（无外层 Scaffold）
      return Row(
        children: [
          _buildDesktopNavigationRail(currentIndex),
          Expanded(
            child: widget.child,
          ),
        ],
      );
    } else {
      // 移动端：Scaffold + 底部导航栏
      // 页面的 Scaffold 会嵌套在这里面
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildMobileNavigationBar(currentIndex),
      );
    }
  }

  /// 桌面端导航栏
  Widget _buildDesktopNavigationRail(int currentIndex) {
    final chatState = ref.watch(chatProvider);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              selectedIndex: currentIndex,
              extended: false,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home),
                  label: const Text('首页'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('套餐'),
                ),
                NavigationRailDestination(
                  icon: _buildIconWithBadge(
                    const Icon(Icons.support_agent),
                    chatState.unreadCount,
                  ),
                  label: const Text('客服'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people),
                  label: const Text('邀请'),
                ),
              ],
              onDestinationSelected: _onDestinationSelected,
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: () {
              // TODO: 切换标签显示/隐藏
            },
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 移动端底部导航栏
  Widget _buildMobileNavigationBar(int currentIndex) {
    final chatState = ref.watch(chatProvider);

    return NavigationBar(
      selectedIndex: currentIndex,
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
      onDestinationSelected: _onDestinationSelected,
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

