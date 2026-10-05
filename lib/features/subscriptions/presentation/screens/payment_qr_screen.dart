import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/activate_code_dialog.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/configuration/feature_flags.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/security/screen_capture_policy.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/models/course_interest_model.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/data/services/qr_image_saver.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/screens/receipt_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:no_screenshot/screenshot_snapshot.dart';

import '../../../../core/routes/router.dart';

enum _InterestSaveOrigin { screenshot, manual, qrDownload }

class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.courseId, this.qrImageSaver});

  final String courseId;
  final QrImageSaver? qrImageSaver;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  final NoScreenshot _noScreenshot = NoScreenshot.instance;
  late final ScreenCaptureLease _captureLease;
  StreamSubscription<ScreenshotSnapshot>? _screenshotSubscription;
  bool _savingInterest = false;
  bool _interestSaved = false;
  bool _downloadingQr = false;
  _InterestSaveOrigin? _interestSaveOrigin;

  @override
  void initState() {
    super.initState();
    _captureLease = ScreenCapturePolicy.instance.temporarilyAllowCapture();
    context.read<SubscriptionBloc>().add(
      LoadCoursePaymentInfo(widget.courseId),
    );
    context.read<AppBloc>().add(GetCustomerServiceEvent());
    _listenForScreenshots();
  }

  Future<void> _listenForScreenshots() async {
    _screenshotSubscription = _noScreenshot.screenshotStream.listen((snapshot) {
      if (snapshot.wasScreenshotTaken) {
        _saveInterest(
          InterestSource.qrScreenshot,
          origin: _InterestSaveOrigin.screenshot,
        );
      }
    });
    try {
      await _noScreenshot.startScreenshotListening();
    } catch (_) {
      // The manual save action remains available on unsupported devices.
    }
  }

  void _saveInterest(
    InterestSource source, {
    _InterestSaveOrigin origin = _InterestSaveOrigin.manual,
  }) {
    if (_savingInterest || _interestSaved) return;
    final info = context.read<SubscriptionBloc>().state.paymentInfo;
    if (info == null || !info.canStartReceiptFlow) return;
    _savingInterest = true;
    _interestSaveOrigin = origin;
    context.read<SubscriptionBloc>().add(
      SaveCourseInterest(courseId: widget.courseId, source: source),
    );
  }

  Future<void> _downloadQr(CoursePaymentInfo info) async {
    if (_downloadingQr) return;
    final qrUrl = info.paymentQrUrl?.trim();
    if (qrUrl == null || qrUrl.isEmpty) return;

    setState(() => _downloadingQr = true);
    try {
      final safeCourseId = widget.courseId.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '_',
      );
      await (widget.qrImageSaver ?? QrImageSaver()).saveFromUrl(
        url: qrUrl,
        fileName: 'coursaty_qr_$safeCourseId',
      );

      if (!mounted) return;
      setState(() => _downloadingQr = false);
      if (_interestSaved) {
        _showSnack('تم تنزيل صورة QR في معرض الصور.');
      } else {
        _saveInterest(
          InterestSource.manual,
          origin: _InterestSaveOrigin.qrDownload,
        );
      }
    } on QrImageSaveException catch (error) {
      if (!mounted) return;
      setState(() => _downloadingQr = false);
      _showSnack(_downloadErrorMessage(error.failure));
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadingQr = false);
      _showSnack('تعذر تنزيل صورة QR. حاول مجددًا.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _downloadErrorMessage(QrImageSaveFailure failure) => switch (failure) {
    QrImageSaveFailure.accessDenied =>
      'تعذر حفظ الصورة. اسمح للتطبيق بالوصول إلى معرض الصور ثم أعد المحاولة.',
    QrImageSaveFailure.network =>
      'تعذر تنزيل صورة QR. تحقق من اتصالك ثم أعد المحاولة.',
    QrImageSaveFailure.notEnoughSpace =>
      'لا توجد مساحة كافية في الجهاز لحفظ صورة QR.',
    QrImageSaveFailure.unsupportedFormat =>
      'صيغة صورة QR غير مدعومة على هذا الجهاز.',
    QrImageSaveFailure.unexpected => 'تعذر حفظ صورة QR. حاول مجددًا.',
  };

  void _openReceipt() {
    final info = context.read<SubscriptionBloc>().state.paymentInfo;
    if (info == null || !info.canStartReceiptFlow) return;
    context.pushPage(
      ReceiptUploadScreen(courseId: widget.courseId, courseName: info.name),
    );
  }

  @override
  void dispose() {
    _screenshotSubscription?.cancel();
    _noScreenshot.stopScreenshotListening();
    _captureLease.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listenWhen: (previous, current) =>
          previous.saveInterestStatus != current.saveInterestStatus,
      listener: (context, state) {
        if (state.saveInterestStatus.isSuccess) {
          final origin = _interestSaveOrigin;
          setState(() {
            _interestSaved = true;
            _savingInterest = false;
            _interestSaveOrigin = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                origin == _InterestSaveOrigin.qrDownload
                    ? 'تم تنزيل صورة QR وحفظ الكورس في اهتماماتي.'
                    : 'تم حفظ الكورس في اهتماماتي. يمكنك رفع الإيصال الآن أو لاحقًا.',
              ),
            ),
          );
        } else if (state.saveInterestStatus.isFailed) {
          final origin = _interestSaveOrigin;
          setState(() => _savingInterest = false);
          _interestSaveOrigin = null;
          _showSnack(
            origin == _InterestSaveOrigin.qrDownload
                ? 'تم تنزيل صورة QR، لكن تعذر حفظ الكورس في اهتماماتي: ${state.errorMessage}'
                : state.errorMessage,
          );
        }
      },
      builder: (context, state) {
        final info = state.paymentInfo;
        return Scaffold(
          appBar: AppBar(title: const Text('الدفع والاشتراك')),
          body: SafeArea(
            child: state.paymentInfoStatus.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.paymentInfoStatus.isFailed
                ? _PaymentMessage(
                    icon: Icons.cloud_off_outlined,
                    text:
                        'تعذر تحميل بيانات الدفع. تحقق من اتصالك ثم أعد المحاولة.',
                    onRetry: () => context.read<SubscriptionBloc>().add(
                      LoadCoursePaymentInfo(widget.courseId),
                    ),
                  )
                : info == null
                ? _PaymentMessage(
                    icon: Icons.qr_code_2_outlined,
                    text:
                        'رمز الدفع غير متاح لهذا الكورس حاليًا. يرجى المحاولة لاحقًا.',
                    onRetry: () => context.read<SubscriptionBloc>().add(
                      LoadCoursePaymentInfo(widget.courseId),
                    ),
                  )
                : !info.canStartReceiptFlow
                ? _PaymentMessage(
                    icon: info.isExpiredNow
                        ? Icons.event_busy_outlined
                        : Icons.block_outlined,
                    text: info.ineligibilityReason,
                    onRetry: () => context.read<SubscriptionBloc>().add(
                      LoadCoursePaymentInfo(widget.courseId),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CourseSummary(info: info),
                              const SizedBox(height: 20),
                              Text(
                                'خطوات الاشتراك',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _StepRow(
                                number: '1',
                                text:
                                    'امسح رمز Qr أو التقط لقطة شاشة لحساب الشام كاش وادفع المبلغ المطلوب',
                              ),
                              const SizedBox(height: 8),
                              const _StepRow(
                                number: '2',
                                text:
                                    'اذهب إلى قسم اهتماماتي الموجود في صفحة اشتراكاتي',
                              ),
                              const SizedBox(height: 8),
                              const _StepRow(
                                number: '3',
                                text:
                                    'ارفع الإيصال ( الإشعار ) للكورس الذي قمت بدفع مبلغه',
                              ),
                              const SizedBox(height: 18),
                              _QrCard(
                                url: info.paymentQrUrl!,
                                size: constraints.maxWidth >= 600 ? 330 : 260,
                                isDownloading: _downloadingQr,
                                onDownload: () => _downloadQr(info),
                              ),
                              const _QrSupportActions(),
                              const SizedBox(height: 18),
                              if (!_interestSaved)
                                CoursatySecondaryButton(
                                  label: _savingInterest
                                      ? 'جارٍ الحفظ...'
                                      : 'حفظ في اهتماماتي',
                                  onPressed: _savingInterest || _downloadingQr
                                      ? null
                                      : () => _saveInterest(
                                          InterestSource.manual,
                                        ),
                                )
                              else ...[
                                CoursatyPrimaryButton(
                                  label: 'رفع الإيصال الآن',
                                  onPressed: _openReceipt,
                                ),
                                const SizedBox(height: 12),
                                CoursatySecondaryButton(
                                  label: 'لاحقًا',
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                              if (SubscriptionFeatureFlags
                                  .showLegacySubscriptionMethods) ...[
                                const SizedBox(height: 24),
                                const _LegacyMethods(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _CourseSummary extends StatelessWidget {
  const _CourseSummary({required this.info});
  final CoursePaymentInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: info.imageUrl == null || info.imageUrl!.isEmpty
                ? Container(
                    width: 56,
                    height: 56,
                    color: colors.surface,
                    child: const Icon(Icons.school_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: info.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.school_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المبلغ المطلوب: ${info.finalPrice} ل.س',
                  style: GoogleFonts.cairo(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text, style: GoogleFonts.cairo(fontSize: 14, height: 1.55)),
      ),
    ],
  );
}

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.url,
    required this.size,
    required this.isDownloading,
    required this.onDownload,
  });
  final String url;
  final double size;
  final bool isDownloading;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: .22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Semantics(
            label: 'رمز QR للدفع الخاص بالكورس',
            image: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.contain,
                placeholder: (_, _) => SizedBox(
                  width: size,
                  height: size,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => SizedBox(
                  width: size,
                  height: size,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_2_outlined, size: 44),
                        SizedBox(height: 8),
                        Text('تعذر تحميل رمز الدفع'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isDownloading ? null : onDownload,
            icon: isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : SvgPicture.asset(
                    AppAssets.iconDownload,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
            label: Text(
              isDownloading ? 'جارٍ تنزيل الصورة...' : 'تنزيل صورة QR',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withValues(alpha: .7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'تنزيل صورة QR أو التقاط لقطة للشاشة يحفظ هذا الكورس تلقائيًا في «اهتماماتي».',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              height: 1.6,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMessage extends StatelessWidget {
  const _PaymentMessage({
    required this.icon,
    required this.text,
    required this.onRetry,
  });
  final IconData icon;
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          CoursatyPrimaryButton(label: 'إعادة المحاولة', onPressed: onRetry),
        ],
      ),
    ),
  );
}

class _QrSupportActions extends StatelessWidget {
  const _QrSupportActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final support = state.customerServiceModel;
        return Column(
          children: [
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 10),
            Text(
              'هل تحتاج مساعدة في الاشتراك؟',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SupportChannelButton(
                    label: 'واتساب',
                    icon: SvgPicture.asset(
                      AppAssets.whatsapp,
                      width: 20,
                      height: 20,
                    ),
                    color: const Color(0xFF25D366),
                    url: support?.whatsappUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SupportChannelButton(
                    label: 'تلغرام',
                    icon: Image.asset(
                      AppAssets.telegramIcon,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    color: const Color(0xFF179CFF),
                    url: support?.telegramUrl,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SupportChannelButton extends StatelessWidget {
  const _SupportChannelButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String label;
  final Widget icon;
  final Color color;
  final String? url;

  Future<void> _open(BuildContext context) async {
    if (url == null || url!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط دعم $label غير متاح حاليًا.')),
      );
      return;
    }
    try {
      await HelperFunctions.urlLauncher(url!);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح $label. حاول مجددًا.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'التواصل مع الدعم عبر $label',
      child: OutlinedButton.icon(
        onPressed: () => _open(context),
        icon: icon,
        label: Text(
          label,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: .7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _LegacyMethods extends StatelessWidget {
  const _LegacyMethods();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'طرق اشتراك أخرى',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 12),
      CoursatySecondaryButton(
        label: 'لديّ كود اشتراك',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ActivateCodeDialog(),
        ),
      ),
      const SizedBox(height: 10),
      CoursatySecondaryButton(
        label: 'نقاط البيع',
        onPressed: () =>
            context.push(GRouter.config.applicationRoutes.pointsOfSale),
      ),
      BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final phone = state.customerServiceModel?.technicalSupportPhone;
          return phone == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CoursatySecondaryButton(
                    label: 'الدعم الفني',
                    onPressed: () => HelperFunctions.openCallApp(phone),
                  ),
                );
        },
      ),
    ],
  );
}
