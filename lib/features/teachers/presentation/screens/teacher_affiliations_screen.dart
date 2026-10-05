import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/teachers/domain/use_case/add_or_remove_affiliations_usecase.dart';
import 'package:coursaty_student_and_teacher/features/teachers/presentation/bloc/teachers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/model/teacher_affilations_model.dart';
import 'add_affiliation_screen.dart';

class TeacherAffiliationsScreen extends StatefulWidget {
  const TeacherAffiliationsScreen({super.key});

  @override
  State<TeacherAffiliationsScreen> createState() =>
      _TeacherAffiliationsScreenState();
}

class _TeacherAffiliationsScreenState extends State<TeacherAffiliationsScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<TeachersBloc>(context).add(GetTeacherAffiliations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(title: "الانتماءات الجامعية"),

      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: context.colorScheme.primary,
      //   onPressed: () {
      //     context.pushPage(AddAffiliationScreen());
      //   },
      //   icon: const Icon(Icons.add),
      //   label: Text(
      //     "إضافة انتماء",
      //     style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
      //   ),
      // ),
      body: BlocBuilder<TeachersBloc, TeachersState>(
        buildWhen: (p, c) => p.affiliationsStatus != c.affiliationsStatus,
        builder: (context, state) {
          final affiliations = state.affiliations ?? [];

          return state.affiliationsStatus.isLoading
              ? Center(child: CoursatyAppLoader())
              : affiliations.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد انتماءات جامعية',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.primary,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<TeachersBloc>(
                      context,
                    ).add(GetTeacherAffiliations());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: affiliations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final affiliation = affiliations[index];

                      return _AffiliationCard(
                        affiliation: affiliation,
                        index: index,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}

class _AffiliationCard extends StatelessWidget {
  const _AffiliationCard({required this.affiliation, required this.index});

  final TeacherAffiliationsResponseModel affiliation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = (index & 1 == 0)
        ? context.colorScheme.primary
        : AppColors.secondary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: context.colorScheme.surface,
        border: Border(right: BorderSide(color: color)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Expanded(
                  child: Text(
                    affiliation.university?.name ?? 'جامعة غير معروفة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),

                // InkWell(
                //   borderRadius: BorderRadius.circular(100),
                //   onTap: () {
                //     showDialog(
                //       context: context,
                //       builder: (_) => DeleteAffiliationConfirmationDialog(
                //         universityId: affiliation.universityId!,
                //         departmentId: affiliation.departmentId,
                //         collegeId: affiliation.collegeId!,
                //       ),
                //     );
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: Colors.red.withValues(alpha: 0.1),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(
                //       Icons.delete_outline_rounded,
                //       color: Color(0xFFC61F1F),
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 18),

            _SingleLineInfo(
              title: 'الكلية',
              value: affiliation.college?.name ?? '-',
            ),

            const SizedBox(height: 12),

            _SingleLineInfo(
              title: 'القسم',
              value: affiliation.department?.name ?? '-',
            ),

            const SizedBox(height: 12),

            _SingleLineInfo(
              title: 'تاريخ الإضافة',
              value: _formatDate(affiliation.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteAffiliationConfirmationDialog extends StatelessWidget {
  const DeleteAffiliationConfirmationDialog({
    super.key,
    required this.universityId,
    required this.collegeId,
    this.departmentId,
  });

  final String universityId, collegeId;
  final String? departmentId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 340,
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
                  icon: const Icon(Icons.close, color: Color(0xFFC61F1F)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              const SizedBox(height: 14),

              const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFC61F1F),
                size: 40,
              ),

              const SizedBox(height: 14),

              Text(
                'هل أنت متأكد أنك تريد حذف هذا الانتماء؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFC61F1F),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x40C61F1F),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      BlocProvider.of<TeachersBloc>(context).add(
                        AddOrDeleteTeacherAffiliations(
                          params: AddOrRemoveAffiliationsParams(
                            universityId: universityId,
                            collegeId: collegeId,
                            departmentId: departmentId,
                            isForDelete: true,
                          ),
                        ),
                      );

                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        'حذف الانتماء',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: Text(
                        'رجوع',
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
    );
  }
}

class _SingleLineInfo extends StatelessWidget {
  const _SingleLineInfo({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.greyNormal,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';

  return DateFormat('yyyy/MM/dd').format(date);
}
