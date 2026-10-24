import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/router.dart';
import '../../services/app_update_service.dart';

/// Asks the server for the admin's release policy at launch and whenever the
/// app comes back to the foreground, then:
/// - a mandatory update covers the app with a dialog that cannot be closed;
/// - an optional one is offered once per new version per app session.
class AppUpdateGate with WidgetsBindingObserver {
  AppUpdateGate._();

  static final AppUpdateGate _instance = AppUpdateGate._();
  static bool _started = false;

  /// Coming back to the app re-checks at most this often.
  static const _recheckEvery = Duration(minutes: 30);

  DateTime? _lastCheck;
  bool _blocking = false;
  int? _offeredBuild;

  static void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(_instance);
    _instance._check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _blocking) return;
    final last = _lastCheck;
    if (last != null && DateTime.now().difference(last) < _recheckEvery) return;
    _check();
  }

  Future<void> _check() async {
    _lastCheck = DateTime.now();
    final info = await AppUpdateService.check();
    if (info == null || !info.updateAvailable) return;
    final context = GRouter.router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    if (info.required) {
      if (_blocking) return;
      _blocking = true;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => _UpdateDialog(info: info),
      );
      return;
    }
    if (_offeredBuild == info.latestBuild) return;
    _offeredBuild = info.latestBuild;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _UpdateDialog(info: info),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.info});

  final AppUpdateInfo info;

  @override
  Widget build(BuildContext context) {
    final hasLink = info.storeUrl != null || info.downloadUrl != null;
    final title = info.required ? 'تحديث مطلوب' : 'تحديث متوفر';
    final body =
        info.message ??
        (info.required
            ? 'صدر إصدار جديد من التطبيق، ولا يمكن متابعة الاستخدام قبل تثبيته.'
            : 'صدر إصدار جديد من التطبيق فيه تحسينات وإصلاحات.');
    return PopScope(
      // A mandatory update cannot be closed with the back button.
      canPop: !info.required,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body, style: GoogleFonts.cairo(height: 1.5)),
              if (info.latestVersion != null) ...[
                const SizedBox(height: 8),
                Text(
                  'الإصدار الجديد: ${info.latestVersion}',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ],
              if (!hasLink) ...[
                const SizedBox(height: 8),
                Text(
                  'تواصل مع الدعم للحصول على الإصدار الجديد.',
                  style: GoogleFonts.cairo(),
                ),
              ],
            ],
          ),
          actions: [
            if (!info.required)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('لاحقاً', style: GoogleFonts.cairo()),
              ),
            if (hasLink)
              FilledButton(
                onPressed: () async {
                  final opened = await AppUpdateService.openUpdate(info);
                  if (!context.mounted) return;
                  if (!opened) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(content: Text('تعذّر فتح رابط التحديث')),
                    );
                  } else if (!info.required) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('تحديث الآن', style: GoogleFonts.cairo()),
              ),
          ],
        ),
      ),
    );
  }
}
