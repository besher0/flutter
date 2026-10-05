import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/router.dart';
import '../bloc/app_bloc.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _contactCard({
    required String label,
    required Color borderColor,
    required Widget icon,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 81,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9EFF0)),
          boxShadow: [
            const BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              icon,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(
          title: "تواصل معنا",
          onBackTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                return state.getCustomerService.isLoading
                    ? CoursatyAppLoader()
                    : RefreshIndicator(
                        onRefresh: () async {
                          BlocProvider.of<AppBloc>(
                            context,
                          ).add(GetCustomerServiceEvent());
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _contactCard(
                                label: 'خدمة العملاء',
                                borderColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                icon: SvgPicture.asset(
                                  AppAssets.customerService,
                                ),
                                onTap: () {
                                  final technical = state
                                      .customerServiceModel
                                      ?.technicalSupportPhone;
                                  final contact = state
                                      .customerServiceModel
                                      ?.contactSupportPhone;
                                  context.push(
                                    "${GRouter.config.applicationRoutes.customerService}?technical=$technical&contact=$contact",
                                  );
                                },
                              ),
                              if (state.customerServiceModel?.whatsappUrl !=
                                  null)
                                _contactCard(
                                  onTap: () {
                                    HelperFunctions.urlLauncher(
                                      state.customerServiceModel!.whatsappUrl!,
                                    );
                                  },
                                  label: 'واتس آب',
                                  borderColor: const Color(0xFF39AC27),
                                  icon: SvgPicture.asset(AppAssets.whatsapp),
                                ),
                              if (state.customerServiceModel?.telegramUrl !=
                                  null)
                                _contactCard(
                                  label: 'تلغرام',
                                  borderColor: const Color(0xFF179CFF),
                                  icon: Container(
                                    padding: EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color(0x7033ABE0),
                                      ),
                                    ),
                                    child: Image.asset(AppAssets.telegramIcon),
                                  ),
                                  onTap: () {
                                    HelperFunctions.urlLauncher(
                                      state.customerServiceModel!.telegramUrl!,
                                    );
                                  },
                                ),
                              if (state.customerServiceModel?.facebookUrl !=
                                  null)
                                _contactCard(
                                  label: 'صفحتنا على الفيسبوك',
                                  borderColor: const Color(0xFF1877F2),
                                  icon: SvgPicture.asset(AppAssets.facebook),
                                  onTap: () {
                                    HelperFunctions.urlLauncher(
                                      state.customerServiceModel!.facebookUrl!,
                                    );
                                  },
                                ),
                              if (state.customerServiceModel?.instagramUrl !=
                                  null)
                                _contactCard(
                                  label: 'صفحتنا على الإنستجرام',
                                  borderColor: const Color(0xFFD62976),
                                  icon: SvgPicture.asset(AppAssets.instagram),
                                  onTap: () {
                                    HelperFunctions.urlLauncher(
                                      state.customerServiceModel!.instagramUrl!,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
