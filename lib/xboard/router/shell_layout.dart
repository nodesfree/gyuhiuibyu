import 'package:fl_clash/xboard/widgets/navigation/desktop_navigation_rail.dart';
import 'package:fl_clash/xboard/widgets/navigation/mobile_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 适配性的 Shell 布局
/// 桌面端：侧边栏 + 内容区
/// 移动端：底部导航栏 + 内容区
class AdaptiveShellLayout extends ConsumerWidget {
  final StatefulNavigationShell child;

  const AdaptiveShellLayout({
    super.key,
    required this.child,
  });

  void _onDestinationSelected(BuildContext context, int index, bool isDesktop) {
    // 使用 go 方法导航，而不是 goBranch
    // 这样可以确保分支被正确初始化
    if (isDesktop) {
      // 桌面端路由：首页、套餐、客服、邀请
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
    } else {
      // 移动端路由：首页、邀请
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/invite');
          break;
      }
    }
  }

  int _getCurrentIndex(BuildContext context, bool isDesktop) {
    final location = GoRouterState.of(context).uri.path;
    
    if (isDesktop) {
      // 桌面端：首页、套餐、客服、邀请
      if (location == '/') return 0;
      if (location.startsWith('/plans')) return 1;
      if (location.startsWith('/support')) return 2;
      if (location.startsWith('/invite')) return 3;
      return 0;
    } else {
      // 移动端：首页、邀请
      if (location.startsWith('/invite')) return 1;
      return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final currentIndex = _getCurrentIndex(context, isDesktop);
    
    if (isDesktop) {
      // 桌面端：侧边栏 + 内容区（无外层 Scaffold）
      return Row(
        children: [
          DesktopNavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, index, true),
          ),
          Expanded(
            child: child,
          ),
        ],
      );
    } else {
      // 移动端：Scaffold + 底部导航栏
      // 页面的 Scaffold 会嵌套在这里面
      return Scaffold(
        body: child,
        bottomNavigationBar: MobileNavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onDestinationSelected(context, index, false),
        ),
      );
    }
  }
}

