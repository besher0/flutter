import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/edit_profile_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/widgets/coursaty_button.dart';
import '../../../../app/widgets/coursaty_dropdown.dart';
import '../../../../app/widgets/coursaty_text_field.dart';
import '../../../../app/widgets/custom_choose_file_button.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../bloc/auth_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.isForTeacher});

  final bool isForTeacher;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController universityNumber = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController telegram = TextEditingController();
  final TextEditingController instagram = TextEditingController();
  final TextEditingController university = TextEditingController();
  final TextEditingController college = TextEditingController();
  final TextEditingController department = TextEditingController();
  final TextEditingController year = TextEditingController();
  final TextEditingController description = TextEditingController();

  final ValueNotifier<XFile?> chooseFile = ValueNotifier(null);

  String? gender = 'MALE';
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

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

  @override
  void initState() {
    super.initState();
    List<String> names = prefsRepository.name?.split(' ') ?? [];
    if (names.isNotEmpty) {
      nameController.text = names[0];
      lastNameController.text = names.length > 1 ? names[1] : '';
      phoneController.text = prefsRepository.phone ?? '';
      universityNumber.text = prefsRepository.universityNumber ?? '';
      gender = prefsRepository.gender;
    }
    initializeTeacher();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TitleAppBar(
        title: GetIt.I<PrefsRepository>().name ?? '',
        onBackTap: () {
          context.pop();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state.profileModel?.teacher?.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(180),
                              child: CachedNetworkImage(
                                imageUrl: state.profileModel!.teacher!.image!,
                                width: 150.r,
                                height: 150.r,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) {
                                  return Icon(Icons.error);
                                },
                              ),
                            )
                          : CircleAvatar(
                              radius: 26,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: SvgPicture.asset(
                                AppAssets.iconBoy,
                                height: 26,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            );
                    },
                  ),
                ),
                CoursatyTextField(
                  label: 'الاسم',
                  hint: 'الاسم',
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                CoursatyTextField(
                  label: 'الكنية',
                  hint: 'الكنية',
                  controller: lastNameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                CoursatyTextField(
                  label: 'رقم الهاتف',
                  hint: 'رقم الهاتف',
                  readOnly: true,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                CoursatyDropdown<String>(
                  label: 'الجنس',
                  hint: 'الجنس',
                  value: gender,
                  onChanged: (v) => setState(() => gender = v!),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('ذكر')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
                  ],
                ),
                const SizedBox(height: 16),
                if (!widget.isForTeacher) ...{
                  CoursatyTextField(
                    label: 'الرقم الجامعي',
                    hint: 'الرقم الجامعي',
                    controller: universityNumber,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    validator: (text) {
                      if (text == null) {
                        return "الرقم الجامعي مطلوب";
                      }
                      if (int.tryParse(text) == null) {
                        return "الرقم الجامعي المدخل غير صالح";
                      }
                      return null;
                    },
                  ),
                  15.verticalSpace,
                },
                if (widget.isForTeacher) ...{
                  CustomChooseFileButton(
                    title: "تغيير صورة الملف الشخصي",
                    usedForImage: true,
                    usedForFile: false,
                    choosedFile: chooseFile,
                  ),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {},
                    buildWhen: (p, c) => p.profileStatus != c.profileStatus,
                    listenWhen: (p, c) => p.profileStatus != c.profileStatus,
                    builder: (context, state) {
                      return state.updateProfileStatus.isLoading
                          ? CoursatyAppLoader()
                          : Column(
                              spacing: 10,
                              children: [
                                CoursatyTextField(
                                  label: 'رابط قناة التلفرام',
                                  hint: 'رابط قناة التلفرام',
                                  controller: telegram,
                                  validator: _validateRequired,
                                ),
                                CoursatyTextField(
                                  label: 'رابط صفحة الانستغرام (اختياري)',
                                  hint: 'رابط صفحة الانستغرام (اختياري)',
                                  controller: instagram,
                                ),
                                CoursatyTextField(
                                  validator: _validateRequired,
                                  label: 'وصف المدرس',
                                  hint: 'وصفي الشخصي',
                                  controller: description,
                                ),
                              ],
                            );
                    },
                  ),
                },
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (p, c) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {});
                    });
                  },
                  listenWhen: (p, c) =>
                      p.updateProfileStatus != c.updateProfileStatus,
                  buildWhen: (p, c) =>
                      p.updateProfileStatus != c.updateProfileStatus,
                  builder: (context, state) {
                    return state.updateProfileStatus.isLoading
                        ? CoursatyAppLoader()
                        : CoursatyPrimaryButton(
                            label: 'حفظ',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<AuthBloc>(context).add(
                                  UpdateProfileEvent(
                                    image: chooseFile.value,
                                    params: UpdateProfileParams(
                                      universityNumber:
                                          universityNumber.text.trim().isEmpty
                                          ? null
                                          : universityNumber.text,
                                      name:
                                          "${nameController.text} ${lastNameController.text}",
                                      phone: phoneController.text,
                                      gender: gender,
                                      telegramUrl: telegram.text.trim().isEmpty
                                          ? null
                                          : telegram.text,
                                      instagramUrl:
                                          instagram.text.trim().isEmpty
                                          ? null
                                          : instagram.text,
                                      description:
                                          description.text.trim().isEmpty
                                          ? null
                                          : description.text,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initializeTeacher() {
    setState(() {
      final profile = GetIt.I<AuthBloc>().state.profileModel;
      telegram.text = profile?.teacher?.telegramUrl ?? '';
      instagram.text = profile?.teacher?.instagramUrl ?? '';
      description.text = profile?.teacher?.description ?? '';
    });
  }
}
