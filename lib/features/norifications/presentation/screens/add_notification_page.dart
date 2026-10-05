import 'package:coursaty_student_and_teacher/app/widgets/coursaty_button.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_dropdown.dart';
import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/core/utils/responsive_padding.dart';
import 'package:coursaty_student_and_teacher/features/norifications/domain/use_case/add_notification_usecase.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/bloc/notifications_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_affilations_model.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNotificationPage extends StatefulWidget {
  const AddNotificationPage({super.key});

  @override
  State<AddNotificationPage> createState() => _AddNotificationPageState();
}

class _AddNotificationPageState extends State<AddNotificationPage> {
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController link;

  late final TextEditingController universityController;
  late final TextEditingController collegeController;
  late final TextEditingController departmentController;

  final GlobalKey<FormState> _globalKey = GlobalKey();

  TeacherAffiliationsResponseModel? selectedAffiliation;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<TeachersBloc>(context).add(GetTeacherAffiliations());

    title = TextEditingController();
    description = TextEditingController();

    universityController = TextEditingController();
    collegeController = TextEditingController();
    link = TextEditingController();
    departmentController = TextEditingController();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();

    link.dispose();
    collegeController.dispose();
    departmentController.dispose();
    departmentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: "إضافة إشعار جديد",
        onBackTap: () => context.pop(),
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _globalKey,

          child: Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 20.0),

            child: Column(
              children: [
                const SizedBox(height: 40),

                BlocBuilder<TeachersBloc, TeachersState>(
                  buildWhen: (p, c) =>
                      p.affiliationsStatus != c.affiliationsStatus,

                  builder: (context, state) {
                    if (state.affiliationsStatus.isLoading) {
                      return Center(child: CoursatyAppLoader());
                    }

                    final affiliations = state.affiliations ?? [];

                    if (affiliations.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.orange.withValues(alpha: 0.1),
                        ),

                        child: const Text('لا توجد انتماءات جامعية متاحة'),
                      );
                    }

                    return CoursatyDropdown<TeacherAffiliationsResponseModel>(
                      label: 'الانتماء الجامعي',
                      hint: 'اختر الانتماء الجامعي',

                      validator: (value) {
                        if (value == null) {
                          return 'الحقل مطلوب';
                        }

                        return null;
                      },

                      onChanged: (item) {
                        if (item == null) return;

                        selectedAffiliation = item;

                        universityController.text = item.universityId ?? '';

                        collegeController.text = item.collegeId ?? '';

                        departmentController.text = item.departmentId ?? '';
                      },

                      items: affiliations
                          .map(
                            (item) =>
                                DropdownMenuItem<
                                  TeacherAffiliationsResponseModel
                                >(
                                  value: item,

                                  child: Text(_buildAffiliationTitle(item)),
                                ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),

                if (selectedAffiliation != null) ...[
                  _InfoTile(
                    title: 'الجامعة',
                    value: selectedAffiliation?.university?.name ?? '-',
                  ),

                  const SizedBox(height: 12),

                  _InfoTile(
                    title: 'الكلية',
                    value: selectedAffiliation?.college?.name ?? '-',
                  ),

                  const SizedBox(height: 12),

                  _InfoTile(
                    title: 'القسم',
                    value: selectedAffiliation?.department?.name ?? '-',
                  ),

                  const SizedBox(height: 16),
                ],

                CoursatyTextField(
                  label: 'عنوان الإشعار',
                  hint: 'عنوان الإشعار',
                  controller: title,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),

                const SizedBox(height: 16),

                CoursatyTextField(
                  label: 'محتوى الإشعار',
                  hint: 'محتوى الإشعار',
                  controller: description,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 5,
                  validator: _requiredValidator,
                ),

                const SizedBox(height: 16),

                CoursatyTextField(
                  label: 'رابط مع الإشعار (اختياري)',
                  hint: 'رابط مع الإشعار (اختياري)',
                  controller: link,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 24),

                BlocConsumer<NotificationsBloc, NotificationsState>(
                  buildWhen: (p, c) =>
                      p.addNotificationsStatus != c.addNotificationsStatus,

                  listenWhen: (p, c) =>
                      p.addNotificationsStatus != c.addNotificationsStatus,

                  listener: (context, state) {
                    if (state.addNotificationsStatus.isFailed) {
                      showMessage(state.errorMessage);
                    }

                    if (state.addNotificationsStatus.isSuccess) {
                      context.pop();
                    }
                  },

                  builder: (context, state) {
                    return state.addNotificationsStatus.isLoading
                        ? CoursatyAppLoader()
                        : CoursatyPrimaryButton(
                            label: 'إرسال',

                            onPressed: () {
                              if (_globalKey.currentState!.validate()) {
                                BlocProvider.of<NotificationsBloc>(context).add(
                                  AddNotificationEvent(
                                    params: AddNotificationParams(
                                      title: title.text,
                                      description: description.text,
                                      collegeId: collegeController.text,
                                      link: link.text.trim().isEmpty
                                          ? null
                                          : link.text.trim(),
                                      departmentId:
                                          departmentController.text.isEmpty
                                          ? null
                                          : departmentController.text,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                  },
                ),

                const SizedBox(height: 16),

                CoursatySecondaryButton(
                  label: "إلغاء",
                  onPressed: () => context.pop(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildAffiliationTitle(TeacherAffiliationsResponseModel affiliation) {
    final university = affiliation.university?.name ?? '';

    final college = affiliation.college?.name ?? '';

    final department = affiliation.department?.name ?? '';

    final values = [
      university,
      if (college.isNotEmpty) college,
      if (department.isNotEmpty) department,
    ];

    return values.join(' - ');
  }

  String? _requiredValidator(dynamic item) {
    if (item == null || item.toString().trim().isEmpty) {
      return "الحقل مطلوب";
    }

    return null;
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),

        color: Theme.of(context).colorScheme.surface,
      ),

      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w700)),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
