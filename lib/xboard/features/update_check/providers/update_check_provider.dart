import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update_check_state.dart';
import '../services/update_service.dart';
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());
final updateCheckProvider =
    StateNotifierProvider<UpdateCheckNotifier, UpdateCheckState>((ref) {
  final updateService = ref.watch(updateServiceProvider);
  return UpdateCheckNotifier(updateService: updateService);
});
class UpdateCheckNotifier extends StateNotifier<UpdateCheckState> {
  final UpdateService _updateService;
  UpdateCheckNotifier({
    required UpdateService updateService,
  })  : _updateService = updateService,
        super(const UpdateCheckState());
  Future<void> initialize() async {
    FeatureLogger.info('开始检查更新', null, 'update_check_provider.dart');
    await checkForUpdates();
  }
  Future<void> refresh() async {
    FeatureLogger.info('刷新检查更新', null, 'update_check_provider.dart');
    await checkForUpdates();
  }
  Future<void> checkForUpdates() async {
    if (!mounted) return;
    state = state.copyWith(
      isChecking: true,
      error: null,
    );
    try {
      final currentVersion = await _updateService.getCurrentVersion();
      FeatureLogger.info('当前版本: $currentVersion', null, 'update_check_provider.dart');
      state = state.copyWith(currentVersion: currentVersion);
      final updateInfo = await _updateService.checkForUpdates();
      if (!mounted) return;
      state = state.copyWith(
        isChecking: false,
        hasUpdate: updateInfo["hasUpdate"] as bool? ?? false,
        latestVersion: updateInfo["latestVersion"]?.toString(),
        updateUrl: updateInfo["updateUrl"]?.toString(),
        releaseNotes: updateInfo["releaseNotes"]?.toString(),
        forceUpdate: updateInfo["forceUpdate"] as bool? ?? false,
      );
      if (state.hasUpdate) {
        FeatureLogger.info('发现新版本: ${state.latestVersion}', null, 'update_check_provider.dart');
        if (state.releaseNotes != null && state.releaseNotes!.isNotEmpty) {
          // FeatureLogger.debug('发布说明: ${state.releaseNotes}', null, 'update_check_provider.dart');
        }
      } else {
        FeatureLogger.info('已是最新版本', null, 'update_check_provider.dart');
      }
    } catch (e) {
      if (!mounted) return;
      FeatureLogger.error('检查更新失败', e, 'update_check_provider.dart');
      state = state.copyWith(
        isChecking: false,
        error: e.toString(),
      );
    }
  }
}