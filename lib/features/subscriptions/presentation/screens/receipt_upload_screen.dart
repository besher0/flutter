import 'dart:io';

import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptUploadScreen extends StatefulWidget {
  const ReceiptUploadScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });
  final String courseId;
  final String courseName;

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  static const _maxBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();
  File? _receipt;
  String? _validationMessage;

  Future<void> _chooseReceipt() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final extension = picked.path.split('.').last.toLowerCase();
    final bytes = await picked.length();
    if (!_allowedExtensions.contains(extension)) {
      setState(
        () => _validationMessage = 'اختر صورة بصيغة JPG أو PNG أو WebP.',
      );
      return;
    }
    if (bytes > _maxBytes) {
      setState(
        () => _validationMessage = 'حجم الصورة يجب ألا يتجاوز 5 ميغابايت.',
      );
      return;
    }
    setState(() {
      _receipt = File(picked.path);
      _validationMessage = null;
    });
  }

  void _submit() {
    if (_receipt == null) {
      setState(() => _validationMessage = 'اختر صورة الإيصال أولًا.');
      return;
    }
    context.read<SubscriptionBloc>().add(
      SubmitSubscriptionReceipt(
        courseId: widget.courseId,
        file: _receipt!,
        note: _noteController.text,
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listenWhen: (previous, current) =>
          previous.receiptStatus != current.receiptStatus,
      listener: (context, state) {
        if (state.receiptStatus.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال الإيصال للمراجعة بنجاح.')),
          );
          context.pop(true);
        } else if (state.receiptStatus.isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage.isEmpty
                    ? 'تعذر إرسال الإيصال. حاول مجددًا.'
                    : state.errorMessage,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isUploading = state.receiptStatus.isLoading;
        return Scaffold(
          appBar: AppBar(title: const Text('رفع إيصال الدفع')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.courseName,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ارفع صورة واضحة للإيصال. الصيغ المقبولة: JPG، PNG، WebP حتى 5 ميغابايت.',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          height: 1.6,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_receipt == null)
                        _PickReceiptCard(
                          onPressed: isUploading ? null : _chooseReceipt,
                        )
                      else
                        _ReceiptPreview(
                          file: _receipt!,
                          onReplace: isUploading ? null : _chooseReceipt,
                          onDelete: isUploading
                              ? null
                              : () => setState(() => _receipt = null),
                        ),
                      if (_validationMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _validationMessage!,
                          style: GoogleFonts.cairo(
                            color: colors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        'ملاحظة للإدارة (اختيارية)',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        enabled: !isUploading,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 400,
                        decoration: const InputDecoration(
                          hintText: 'مثال: تم الدفع باسم الطالب...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (isUploading) ...[
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: state.uploadProgress == 0
                              ? null
                              : state.uploadProgress,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'جارٍ رفع الإيصال… ${(state.uploadProgress * 100).round()}%',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 16),
                      CoursatyPrimaryButton(
                        label: isUploading
                            ? 'جارٍ الإرسال...'
                            : state.receiptStatus.isFailed
                            ? 'إعادة إرسال الإيصال'
                            : 'إرسال الإيصال للمراجعة',
                        isLoading: isUploading,
                        onPressed: isUploading ? null : _submit,
                      ),
                    ],
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

class _PickReceiptCard extends StatelessWidget {
  const _PickReceiptCard({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      height: 190,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .35),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 46),
          const SizedBox(height: 12),
          Text(
            'اختيار صورة من المعرض',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.file,
    required this.onReplace,
    required this.onDelete,
  });
  final File file;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            height: 230,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('استبدال'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onDelete,
              tooltip: 'حذف الصورة',
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    ),
  );
}
