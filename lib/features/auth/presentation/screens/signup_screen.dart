import 'package:coursaty_student_and_teacher/core/routes/router.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/sign_up_use_case.dart';
import 'package:coursaty_student_and_teacher/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/widgets/coursaty_button.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/common/helper/show_message.dart';
import '../../data/model/education_model.dart';
import '../widgets/confirm_step.dart';
import '../widgets/password_data_step.dart';
import '../widgets/personal_data_step.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/university_data_step.dart';

/// Sign-up flow: 3 stages (personal data, university data, password), then confirm/success.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.isForTeacher});

  final bool isForTeacher;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final int _totalSteps = widget.isForTeacher ? 3 : 4;
  final _pageController = PageController(initialPage: 0);
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // student & teacher
  final _lastNameController = TextEditingController(); // student & teacher
  final _phoneController = TextEditingController(); // student & teacher
  final _universityController = TextEditingController(); // student & teacher
  final _collegeController = TextEditingController(); // student & teacher
  final _departmentController = TextEditingController(); // student & teacher
  final _passwordController = TextEditingController(); // student & teacher
  final _passwordConfirmController =
      TextEditingController(); // student & teacher

  final EducationInfo _educationInfo = EducationInfo(); // student
  final _yearController = TextEditingController(); // student
  final _universityNumberController = TextEditingController(); // student

  final _description = TextEditingController(); // teacher
  final _teacherInstagram = TextEditingController(); // teacher
  final _teacherTelegram = TextEditingController(); // teacher

  String _gender = "MALE"; // student & teacher

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }

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
    if (password.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _next() {
    if ((_formKey.currentState?.validate() ?? false)) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        final userName = "${_nameController.text} ${_lastNameController.text}";
        final ParamSignUp params = ParamSignUp(
          phone: _phoneController.text,
          userableType: widget.isForTeacher ? "TEACHER" : "STUDENT",
          password: _passwordController.text,
          // will be initialized later
          name: userName,
          gender: _gender,
          teacherParams: widget.isForTeacher
              ? CreateTeacherParams(
                  name: userName,
                  description: _description.text,
                  instagramUrl: _teacherInstagram.text.trim().isEmpty
                      ? null
                      : _teacherInstagram.text,
                  telegramUrl: _teacherTelegram.text,
                  universityId: _universityController.text,
                  collegeId: _collegeController.text,
                  departmentId: _departmentController.text.trim().isEmpty
                      ? null
                      : _departmentController.text,
                )
              : null,
          studentParams: widget.isForTeacher
              ? null
              : CreateStudentParams(
                  name: userName,
                  universityNumber: _universityNumberController.text,
                  universityId: _universityController.text,
                  collegeId: _collegeController.text,
                  departmentId: _departmentController.text == ''
                      ? null
                      : _departmentController.text,
                  collegeYearId: _yearController.text,
                ),
        );
        BlocProvider.of<AuthBloc>(context).add(SignUpEvent(params: params));
      }
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _showSuccessAndNavigate() {
    context.go(
      "${GRouter.config.applicationRoutes.signupSuccess}/${widget.isForTeacher}",
    );
  }

  void _goToLogin() {
    context.go(GRouter.config.applicationRoutes.login);
  }

  String get _title {
    switch (_currentStep) {
      case 0:
        return 'البيانات الشخصية';
      case 1:
        return 'البيانات الجامعية';
      case 2:
        return 'كلمة المرور';
      case 3:
        return 'تأكيد البيانات';
      default:
        return '';
    }
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SizedBox(
            height: 1.sh,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          PersonalDataStep(
                            isActiveStep: _currentStep == 0,
                            nameController: _nameController,
                            lastNameController: _lastNameController,
                            phoneController: _phoneController,
                            gender: _gender,
                            isForTeacher: widget.isForTeacher,
                            description: _description,
                            onGenderChanged: (v) =>
                                setState(() => _gender = v!),
                            requiredValidator: _validateRequired,
                            phoneValidator: _validatePhone,
                            teacherInstagram: _teacherInstagram,
                            teacherTelegram: _teacherTelegram,
                          ),
                          _buildButtons(),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          _buildHeader(),
                          UniversityDataStep(
                            isForTeacher: widget.isForTeacher,
                            universityController: _universityController,
                            universityNumberController:
                                _universityNumberController,
                            collegeController: _collegeController,
                            departmentController: _departmentController,
                            yearController: _yearController,
                            educationInfo: _educationInfo,
                            isActiveStep: _currentStep == 1,
                          ),
                          _buildButtons(),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          _buildHeader(),
                          PasswordStep(
                            isActiveStep: _currentStep == 2,
                            passwordController: _passwordController,
                            passwordConfirmController:
                                _passwordConfirmController,
                            passwordValidator: _validatePassword,
                          ),
                          _buildButtons(),
                        ],
                      ),
                    ),
                    if (!widget.isForTeacher)
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            ConfirmStep(
                              name: _nameController.text,
                              lastName: _lastNameController.text,
                              phone: _phoneController.text,
                              gender: _gender,
                              educationInfo: _educationInfo,
                            ),
                            _buildButtons(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_pageController.hasClients &&
                  (_pageController.page?.toInt() ?? 0) > 0)
                IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back, size: 30),
                  color: Theme.of(context).colorScheme.primary,
                ),
              Expanded(
                child: StepProgressIndicator(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (p, c) => p.createUser != c.createUser,
            buildWhen: (p, c) => p.createUser != c.createUser,
            listener: (context, state) {
              if (state.createUser.isFailed) {
                showMessage(state.errorMessage);
              }
              if (state.createUser.isSuccess) {
                _showSuccessAndNavigate();
              }
            },
            builder: (context, state) {
              return state.createUser.isLoading
                  ? CoursatyAppLoader()
                  : CoursatyPrimaryButton(
                      label: _currentStep == _totalSteps - 1
                          ? 'تأكيد'
                          : 'التالي',
                      onPressed: _next,
                    );
            },
          ),
          const SizedBox(height: 16),
          CoursatySecondaryButton(
            label: _currentStep > 0 ? "تراجع" : 'إلغاء',
            onPressed: _back,
          ),
        ],
      ),
    );
  }
}
