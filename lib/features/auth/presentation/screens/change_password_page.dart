import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/change_password_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController passwordConfirmController =
      TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  String? passwordValidator(String? value) {
    final password = value ?? '';

    if (password.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    return null;
  }

  bool get _didFillAnything {
    return currentPasswordController.text.trim().isNotEmpty ||
        passwordController.text.trim().isNotEmpty ||
        passwordConfirmController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: "تغيير كلمة المرور",
          onBackTap: () {
            context.pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CoursatyTextField(
                    label: 'كلمة المرور الحالية',
                    hint: '*********',
                    controller: currentPasswordController,
                    withObscureText: true,
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 16),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CoursatyTextField(
                        label: 'كلمة المرور الجديدة',
                        hint: '*********',
                        controller: passwordController,
                        withObscureText: true,
                        validator: passwordValidator,
                      ),
                      const SizedBox(height: 16),
                      CoursatyTextField(
                        label: 'تأكيد كلمة المرور الجديدة',
                        hint: '*********',
                        controller: passwordConfirmController,
                        withObscureText: true,
                        validator: (v) {
                          final confirm = v ?? '';

                          if (confirm.trim().isEmpty) {
                            return 'تأكيد كلمة المرور مطلوب';
                          }

                          if (confirm.length < 8) {
                            return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                          }

                          if (confirm != passwordController.text) {
                            return 'غير متطابقة';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (p, c) => p.changePassword != c.changePassword,
                    listener: (context, state) {
                      if (state.changePassword.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم تغيير كلمة المرور بنجاح",
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        );

                        context.pop();
                      }

                      if (state.changePassword.isFailed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.errorMessage,
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        );
                      }
                    },
                    buildWhen: (p, c) => p.changePassword != c.changePassword,
                    builder: (context, state) {
                      return state.changePassword.isLoading
                          ? Center(child: CoursatyAppLoader())
                          : CoursatyPrimaryButton(
                              label: "حفظ",
                              onPressed: () {
                                if (!_didFillAnything) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "يرجى تعبئة الحقول المطلوبة",
                                        style: GoogleFonts.cairo(),
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  if (currentPasswordController.text ==
                                      passwordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "كلمة المرور الجديدة يجب أن تكون مختلفة عن الحالية",
                                          style: GoogleFonts.cairo(),
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  BlocProvider.of<AuthBloc>(context).add(
                                    ChangePasswordEvent(
                                      params: ChangePasswordParams(
                                        currentPassword:
                                            currentPasswordController.text,
                                        newPassword: passwordController.text,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
