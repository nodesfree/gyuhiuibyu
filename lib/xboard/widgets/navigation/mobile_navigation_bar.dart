import 'package:flutter/material.dart';

/// 移动端底部导航栏
class MobileNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const MobileNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      height: 60,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home, size: 22),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.people, size: 22),
          label: '邀请',
        ),
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }
}

