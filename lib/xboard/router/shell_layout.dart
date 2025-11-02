import 'package:fl_clash/xboard/widgets/navigation/desktop_navigation_rail.dart';
import 'package:fl_clash/xboard/widgets/navigation/mobile_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          DesktopNavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: _onDestinationSelected,
          ),
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
        bottomNavigationBar: MobileNavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      );
    }
  }
}

