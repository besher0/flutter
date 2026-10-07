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
    if ((value ?? '').trim().isEmpty) return 'ظ‡ط°ط§ ط§ظ„ط­ظ‚ظ„ ظ…ط·ظ„ظˆط¨';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ ظ…ط·ظ„ظˆط¨';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ ظٹط¬ط¨ ط£ظ† ظٹط­طھظˆظٹ ط£ط±ظ‚ط§ظ… ظپظ‚ط·';
    }
    if (phone.length != 10)
      return 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ ظٹط¬ط¨ ط£ظ† ظٹظƒظˆظ† 10 ط£ط±ظ‚ط§ظ…';
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
                  label: 'ط§ظ„ط§ط³ظ…',
                  hint: 'ط§ظ„ط§ط³ظ…',
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                CoursatyTextField(
                  label: 'ط§ظ„ظƒظ†ظٹط©',
                  hint: 'ط§ظ„ظƒظ†ظٹط©',
                  controller: lastNameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                CoursatyTextField(
                  label: 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ',
                  hint: 'ط±ظ‚ظ… ط§ظ„ظ‡ط§طھظپ',
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
                  label: 'ط§ظ„ط¬ظ†ط³',
                  hint: 'ط§ظ„ط¬ظ†ط³',
                  value: gender,
                  onChanged: (v) => setState(() => gender = v!),
                  validator: (v) => v == null || v.isEmpty
                      ? 'ظ‡ط°ط§ ط§ظ„ط­ظ‚ظ„ ظ…ط·ظ„ظˆط¨'
                      : null,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('ط°ظƒط±')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('ط£ظ†ط«ظ‰')),
                  ],
                ),
                const SizedBox(height: 16),
                if (!widget.isForTeacher) ...{
                  CoursatyTextField(
                    label: 'ط§ظ„ط±ظ‚ظ… ط§ظ„ط¬ط§ظ…ط¹ظٹ',
                    hint: 'ط§ظ„ط±ظ‚ظ… ط§ظ„ط¬ط§ظ…ط¹ظٹ',
                    controller: universityNumber,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    validator: (text) {
                      if (text == null) {
                        return "ط§ظ„ط±ظ‚ظ… ط§ظ„ط¬ط§ظ…ط¹ظٹ ظ…ط·ظ„ظˆط¨";
                      }
                      if (int.tryParse(text) == null) {
                        return "ط§ظ„ط±ظ‚ظ… ط§ظ„ط¬ط§ظ…ط¹ظٹ ط§ظ„ظ…ط¯ط®ظ„ ط؛ظٹط± طµط§ظ„ط­";
                      }
                      return null;
                    },
                  ),
                  15.verticalSpace,
                },
                if (widget.isForTeacher) ...{
                  CustomChooseFileButton(
                    title: "طھط؛ظٹظٹط± طµظˆط±ط© ط§ظ„ظ…ظ„ظپ ط§ظ„ط´ط®طµظٹ",
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
                                  label:
                                      'ط±ط§ط¨ط· طµظپط­ط© ط§ظ„ط§ظ†ط³طھط؛ط±ط§ظ… (ط§ط®طھظٹط§ط±ظٹ)',
                                  hint:
                                      'ط±ط§ط¨ط· طµظپط­ط© ط§ظ„ط§ظ†ط³طھط؛ط±ط§ظ… (ط§ط®طھظٹط§ط±ظٹ)',
                                  controller: instagram,
                                ),
                                CoursatyTextField(
                                  validator: _validateRequired,
                                  label: 'ظˆطµظپ ط§ظ„ظ…ط¯ط±ط³',
                                  hint: 'ظˆطµظپظٹ ط§ظ„ط´ط®طµظٹ',
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
                            label: 'ط­ظپط¸',
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
      instagram.text = profile?.teacher?.instagramUrl ?? '';
      description.text = profile?.teacher?.description ?? '';
    });
  }
}
