import 'dart:io';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart';

import 'package:fl_clash/xboard/features/subscription/widgets/subscription_status_dialog.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';

import 'subscription_status_service.dart';
class SubscriptionStatusChecker {
  static final SubscriptionStatusChecker _instance = SubscriptionStatusChecker._internal();
  factory SubscriptionStatusChecker() => _instance;
  SubscriptionStatusChecker._internal();
  bool _isChecking = false;
  DateTime? _lastCheckTime;
  Future<void> checkSubscriptionStatusOnStartup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;
    final now = DateTime.now();
    if (_isChecking) {
      commonPrint.log('[SubscriptionStatusChecker] 订阅状态检查正在进行中，跳过重复请求');
      return;
    }
    if (_lastCheckTime != null && now.difference(_lastCheckTime!).inSeconds < 30) {
      commonPrint.log('[SubscriptionStatusChecker] 距离上次检查不到30秒，跳过重复请求');
      return;
    }
    _isChecking = true;
    _lastCheckTime = now;
    try {
      commonPrint.log('[SubscriptionStatusChecker] 开始检查订阅状态...');
      final userNotifier = ref.read(xboardUserProvider.notifier);
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) {
        commonPrint.log('[SubscriptionStatusChecker] 用户未登录，跳过订阅状态检查');
        return;
      }
      commonPrint.log('[SubscriptionStatusChecker] 用户已登录，开始获取订阅状态...');
      await userNotifier.refreshSubscriptionInfo();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      final updatedUserState = ref.read(xboardUserProvider);
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: updatedUserState,
        profileSubscriptionInfo: profileSubscriptionInfo,
      );
      commonPrint.log('[SubscriptionStatusChecker] 订阅状态检查结果: ${statusResult.type}');
      commonPrint.log('[SubscriptionStatusChecker] 是否需要弹窗: ${statusResult.shouldShowDialog}');
      if (subscriptionStatusService.shouldShowStartupDialog(statusResult)) {
        await _showSubscriptionStatusDialog(
          context,
          ref,
          statusResult,
        );
      } else {
        if (statusResult.type == SubscriptionStatusType.valid && 
            updatedUserState.subscriptionInfo?.subscribeUrl?.isNotEmpty == true) {
          commonPrint.log('[SubscriptionStatusChecker] 订阅状态正常，开始导入配置...');
          ref.read(profileImportProvider.notifier).importSubscription(
            updatedUserState.subscriptionInfo!.subscribeUrl!
          );
        }
      }
    } catch (e) {
      commonPrint.log('[SubscriptionStatusChecker] 检查订阅状态时出错: $e');
    } finally {
      _isChecking = false;
    }
  }
  Future<void> _showSubscriptionStatusDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatusResult statusResult,
  ) async {
    if (!context.mounted) return;
    commonPrint.log('[SubscriptionStatusChecker] 显示订阅状态弹窗: ${statusResult.type}');
    final result = await SubscriptionStatusDialog.show(
      context,
      statusResult,
      onPurchase: () async {
        await _handleRenewFromDialog(context, ref);
      },
      onRefresh: () async {
        commonPrint.log('[SubscriptionStatusChecker] 刷新订阅状态...');
        await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          await checkSubscriptionStatusOnStartup(context, ref);
        }
      },
    );
    commonPrint.log('[SubscriptionStatusChecker] 弹窗操作结果: $result');
    if (result == 'later' || result == null) {
      commonPrint.log('[SubscriptionStatusChecker] 用户选择稍后处理');
    }
  }
  
  Future<void> _handleRenewFromDialog(BuildContext context, WidgetRef ref) async {
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    
    // 尝试获取用户当前订阅的套餐ID
    final userState = ref.read(xboardUserProvider);
    final currentPlanId = userState.subscriptionInfo?.planId;
    
    if (currentPlanId != null) {
      commonPrint.log('[SubscriptionStatusChecker] 尝试查找套餐ID: $currentPlanId');
      
      // 确保套餐列表已加载
      var plans = ref.read(xboardSubscriptionProvider);
      if (plans.isEmpty) {
        commonPrint.log('[SubscriptionStatusChecker] 套餐列表为空，先加载套餐列表');
        await ref.read(xboardSubscriptionProvider.notifier).loadPlans();
        plans = ref.read(xboardSubscriptionProvider);
      }
      
      final currentPlan = plans.cast<PlanData?>().firstWhere(
        (plan) => plan?.id == currentPlanId,
        orElse: () => null,
      );
      
      if (currentPlan != null) {
        commonPrint.log('[SubscriptionStatusChecker] 找到当前套餐，跳转到购买页面: ${currentPlan.name}');
        if (isDesktop) {
          // 桌面端：通过URL参数传递套餐ID，Plans页面内部会显示购买界面
          context.go('/plans?planId=$currentPlanId');
        } else {
          // 移动端：直接跳转到全屏购买页面
          context.push('/plans/purchase', extra: currentPlan);
        }
        return;
      } else {
        commonPrint.log('[SubscriptionStatusChecker] 未找到ID为 $currentPlanId 的套餐');
      }
    }
    
    // 没找到套餐：跳转到套餐列表页面
    commonPrint.log('[SubscriptionStatusChecker] 跳转到套餐列表页面');
    if (isDesktop) {
      context.go('/plans');
    } else {
      context.push('/plans');
    }
  }
  Future<void> manualCheckSubscriptionStatus(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await checkSubscriptionStatusOnStartup(context, ref);
  }
  bool shouldShowSubscriptionReminder(WidgetRef ref) {
    try {
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) return false;
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubscriptionInfo,
      );
      return subscriptionStatusService.shouldShowStartupDialog(statusResult);
    } catch (e) {
      commonPrint.log('[SubscriptionStatusChecker] 检查订阅提醒状态出错: $e');
      return false;
    }
  }
  String getSubscriptionStatusText(BuildContext context, WidgetRef ref) {
    try {
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) return '未登录';
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubscriptionInfo,
      );
      return statusResult.getMessage(context);
    } catch (e) {
      return '状态检查失败';
    }
  }
}
final subscriptionStatusChecker = SubscriptionStatusChecker();