import 'dart:async';

import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/log_in_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/coursaty_button.dart';
import '../../../../app/widgets/coursaty_text_field.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/utils/extensions/build_context.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../bloc/auth_bloc.dart';
import 'create_guest_screen.dart';

/// Login: title, phone + password fields, forgot/remember, primary button, sign up link.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  Timer? _timer;

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'رقم الهاتف مطلوب';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'رقم الهاتف يجب أن يحتوي أرقام فقط';
    }
    if (phone.length != 10) return 'رقم الهاتف يجب أن يكون 10 أرقام';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.trim().isEmpty) return 'كلمة المرور مطلوبة';
    if (password.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      BlocProvider.of<AuthBloc>(context).add(
        LogInEvent(
          params: ParamLogIn(
            phone: _phoneController.text,
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  void markUserAsGuest() {
    GetIt.I<PrefsRepository>().setIsGuest(true);
  }

  void makeOnBoardingSeen() {
    GetIt.I<PrefsRepository>().setOnBoardingSeen(true);
  }

  void _guestSuccess() {
    makeOnBoardingSeen();
    markUserAsGuest();
    context.go(GRouter.config.applicationRoutes.home);
  }

  void initTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 5), () {
      _goToSignUpTeacher();
    });
  }

  void _goToSignUpStudent() {
    context.go("${GRouter.config.applicationRoutes.signup}/false");
  }

  void _goToSignUpTeacher() {
    context.go("${GRouter.config.applicationRoutes.signup}/true");
  }

  void _navigateToSplashToCheckUserAccountActivity() {
    context.go(GRouter.config.applicationRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'تسجيل الدخول',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CoursatyTextField(
                    label: 'رقم الهاتف',
                    hint: 'رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                  CoursatyTextField(
                    label: 'كلمة المرور',
                    hint: '*********',
                    controller: _passwordController,
                    withObscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: _validatePassword,
                  ),
                  // const SizedBox(height: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {},
                  //       child: Text(
                  //         'نسيت كلمة المرور؟',
                  //         style: GoogleFonts.cairo(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w500,
                  //           color: Theme.of(context).colorScheme.primary,
                  //           decoration: TextDecoration.underline,
                  //           decorationColor: Theme.of(context).colorScheme.primary,
                  //         ),
                  //       ),
                  //     ),
                  //     Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Text(
                  //           'تذكر معلومات دخولي',
                  //           style: GoogleFonts.cairo(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w400,
                  //             color: AppColors.textBody,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 4),
                  //         GestureDetector(
                  //           onTap: () =>
                  //               setState(() => _rememberMe = !_rememberMe),
                  //           child: Container(
                  //             width: 10,
                  //             height: 10,
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.rectangle,
                  //               borderRadius: BorderRadius.circular(2),
                  //               border: Border.all(color: Theme.of(context).colorScheme.primary),
                  //               color: _rememberMe
                  //                   ? Theme.of(context).colorScheme.primary
                  //                   : Colors.transparent,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 40),
                  BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (p, c) => p.authStatus != c.authStatus,
                    buildWhen: (p, c) => p.authStatus != c.authStatus,
                    listener: (context, state) {
                      if (state.authStatus.isFailed) {
                        showMessage(state.errorMessage);
                      }
                      if (state.authStatus.isSuccess) {
                        _navigateToSplashToCheckUserAccountActivity();
                      }
                    },
                    builder: (context, state) {
                      return state.authStatus.isLoading
                          ? CoursatyAppLoader()
                          : CoursatyPrimaryButton(
                              label: 'تسجيل دخول',
                              onPressed: _submit,
                            );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _goToSignUpStudent,
                        onTapDown: (_) {
                          initTimer();
                        },
                        onTapUp: (_) {
                          _timer?.cancel();
                        },
                        child: Text(
                          'إنشاء حساب جديد',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<AuthBloc, AuthState>(
                    buildWhen: (p, c) =>
                        p.getOrCreateGuest != c.getOrCreateGuest,
                    listenWhen: (p, c) =>
                        p.getOrCreateGuest != c.getOrCreateGuest,
                    listener: (context, state) {
                      if (state.getOrCreateGuest.isSuccess) {
                        _guestSuccess();
                      } else if (state.getOrCreateGuest.isFailed &&
                          state.isNotFoundGuestError) {
                        context.pushPage(CreateGuestScreen());
                      }
                    },
                    builder: (context, state) {
                      return state.getOrCreateGuest.isLoading
                          ? Center(child: CoursatyAppLoader())
                          : InkWell(
                              onTap: () {
                                BlocProvider.of<AuthBloc>(
                                  context,
                                ).add(GetGuestEvent());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Text(
                                    'أكمل التصفّح كزائر',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                  Container(
                                    padding: HWEdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
