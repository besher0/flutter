import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/common/helper/show_message.dart';
import '../../core/routes/router.dart';
import '../../core/theme/app_colors.dart';

class ActivateCodeDialog extends StatefulWidget {
  const ActivateCodeDialog({super.key, this.onActivated});

  final VoidCallback? onActivated;

  @override
  State<ActivateCodeDialog> createState() => _ActivateCodeDialogState();
}

class _ActivateCodeDialogState extends State<ActivateCodeDialog> {
  final _controller = TextEditingController();

  static const int maxCodeLength = 8;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    String value = _controller.text;

    // Remove spaces and line breaks
    value = value.replaceAll(RegExp(r'\s+'), '');

    // Limit length
    if (value.length > maxCodeLength) {
      value = value.substring(0, maxCodeLength);
    }

    if (value != _controller.text) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _activateCode() {
    if (_controller.text.length == maxCodeLength) {
      BlocProvider.of<AppBloc>(context).add(ScanCodeEvent(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (p, c) => p.scanCode != c.scanCode,
      listener: (context, state) {
        if (state.scanCode.isFailed) {
          showMessage(state.errorMessage);
        }
        if (state.scanCode.isSuccess && state.currentScannedCourseId != null) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          context.push(
            "${GRouter.config.applicationRoutes.courseDetails}/${state.currentScannedCourseId}",
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          width: 1.sw,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 4),

                Column(
                  children: [
                    Icon(
                      Icons.qr_code_2_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 50,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'أدخل هنا الكود لتفعيل',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0D5A5B),
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  enableInteractiveSelection: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(maxCodeLength),
                  ],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXXXXXX',
                    counterText: '',
                    filled: true,
                    fillColor: context.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryLightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _activateCode(),
                ),

                const SizedBox(height: 30),

                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return state.scanCode.isLoading
                        ? CoursatyAppLoader()
                        : Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [AppColors.buttonShadow],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _activateCode,
                                child: Center(
                                  child: Text(
                                    'اشترك',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),

                const SizedBox(height: 12),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          'إلغاء',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.greyDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
