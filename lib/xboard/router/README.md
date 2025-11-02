# XBoard 路由系统

## 概述

基于 **go_router** 实现的现代化、类型安全的路由系统，完全替代了 FL-Clash 原有的 PageView + PageMixin 架构。

## 架构特点

### ✅ 优势

1. **类型安全**：编译时路由检查
2. **声明式**：清晰的路由定义
3. **URL 支持**：支持 Web 和深度链接
4. **嵌套路由**：Shell Route 支持侧边栏布局
5. **自动返回按钮**：无需手动管理
6. **认证重定向**：自动处理登录状态
7. **桌面/移动适配**：响应式布局

## 文件结构

```
lib/xboard/router/
├── app_router.dart          # 导出文件
├── routes.dart              # 路由定义
├── shell_layout.dart        # Shell 布局（侧边栏+内容区）
└── README.md                # 本文档
```

## 已集成的路由

### 主框架路由（Shell Route）

这些页面在侧边栏/底部导航栏中，共享统一的布局：

| 路径 | 页面 | 说明 |
|------|------|------|
| `/` | XBoardHomePage | 首页/订阅信息 |
| `/plans` | PlansView | 套餐列表 |
| `/support` | OnlineSupportPage | 在线客服 |
| `/invite` | InvitePage | 邀请页面 |

### 独立路由（全屏）

这些页面独立显示，不在 Shell 布局内：

| 路径 | 页面 | 说明 |
|------|------|------|
| `/plans/purchase` | PlanPurchasePage | 套餐购买 |
| `/payment/gateway` | PaymentGatewayPage | 支付网关 |
| `/subscription` | SubscriptionPage | 订阅详情 |
| `/login` | LoginPage | 登录 |
| `/register` | RegisterPage | 注册 |
| `/forgot-password` | ForgotPasswordPage | 忘记密码 |
| `/loading` | LoadingPage | 加载中 |

## 导航方式

### 基本导航

```dart
// 跳转到指定路由
context.go('/plans');

// 压栈导航（可返回）
context.push('/plans/purchase', extra: planData);

// 返回
context.pop();
```

### 传递参数

```dart
// 使用 extra 传递复杂对象
context.push('/plans/purchase', extra: plan);

// 在路由定义中接收
pageBuilder: (context, state) {
  final plan = state.extra as PlanData;
  return PlanPurchasePage(plan: plan);
}
```

## 认证重定向

路由系统自动处理认证状态：

```dart
// application.dart 中的逻辑
redirect: (context, state) {
  final isAuthenticated = userState.isAuthenticated;
  final isInitialized = userState.isInitialized;
  
  if (!isInitialized) return '/loading';  // 初始化中
  if (!isAuthenticated) return '/login';   // 未登录
  if (isAuthenticated && isLoginPage) return '/'; // 已登录
  
  return null; // 不重定向
}
```

## 响应式布局

- **桌面端（>600px）**：侧边栏 + 内容区
- **移动端（≤600px）**：底部导航栏 + 内容区

Shell Layout 自动适配，无需手动处理。

## 已更新的页面

以下页面已从 `Navigator.push` 迁移到 `go_router`：

- ✅ `PlansView` → 使用 `context.push('/plans/purchase', extra: plan)`
- ✅ `LoginPage` → 使用 `context.push('/register')` 和 `context.push('/forgot-password')`
- ✅ `XBoardHomePage` → 使用 `context.go('/plans')` 和 `context.go('/support')`

## 待优化项

### 1. 类型安全的路由生成

可以使用 `go_router_builder` 生成类型安全的路由：

```dart
// 未来可以这样使用
const PlansRoute().go(context);
PlanPurchaseRoute(planId: '123').push(context);
```

### 2. 路由守卫

可以添加更多路由守卫逻辑：
- 权限检查
- 订阅状态验证
- 页面访问记录

### 3. 深度链接

配置深度链接支持：
- `app://xboard/plans/purchase/123`
- 分享链接功能

## 迁移指南

### 从旧路由迁移

**旧方式（已废弃）：**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => SomePage(data: data),
  ),
);
```

**新方式：**
```dart
context.push('/some-page', extra: data);
```

### PageMixin 迁移

**旧方式（已废弃）：**
```dart
class MyPage extends StatefulWidget with PageMixin {
  @override
  Widget? get leading => ...;
  
  @override
  List<Widget> get actions => ...;
}
```

**新方式：**
```dart
class MyPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ...,  // 自动有返回按钮
        actions: [...],
      ),
      body: ...,
    );
  }
}
```

## 性能优势

1. **按需加载**：页面只在访问时创建
2. **无状态管理复杂度**：不需要 PageController
3. **标准化**：使用 Flutter 官方推荐方案
4. **易于调试**：可以在 DevTools 中查看路由栈

## 相关资源

- [go_router 官方文档](https://pub.dev/packages/go_router)
- [Flutter 路由最佳实践](https://docs.flutter.dev/ui/navigation)
- [go_router_builder](https://pub.dev/packages/go_router_builder)

---

**重构完成时间**: 2025-01-01  
**路由数量**: 11 个  
**版本**: go_router ^14.6.2

