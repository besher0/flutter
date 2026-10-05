import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/norifications/data/model/notification_model.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/empty_notifications.dart';
import '../widgets/notification_tile.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotificationsBloc>(context).add(GetNotificationsEvent());
  }

  void _onBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: "الإشعارات", onBackTap: _onBack),
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push(GRouter.config.applicationRoutes.addNotification);
          },
          child: Icon(Icons.add, color: AppColors.textLight),
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                indicatorColor: AppColors.secondary,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.greyNormal,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                dividerColor: Theme.of(context).colorScheme.surface,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  insets: const EdgeInsets.symmetric(horizontal: 40),
                ),
                tabs: const [
                  Tab(text: 'الفعالة'),
                  Tab(text: 'المعلقة'),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state.getNotificationsStatus.isLoading) {
                    return Center(child: CoursatyAppLoader());
                  }
                  List<Notification> notifications = state.notifications;
                  String pendingStatus = 'PENDING';
                  final pending = notifications
                      .where((item) => item.status == pendingStatus)
                      .toList();
                  final active = notifications
                      .where((item) => item.status != pendingStatus)
                      .toList();
                  return Expanded(
                    child: TabBarView(
                      children: [
                        if (active.isEmpty)
                          EmptyNotificationsState()
                        else
                          RefreshIndicator(
                            onRefresh: () async {
                              BlocProvider.of<NotificationsBloc>(
                                context,
                              ).add(GetNotificationsEvent());
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: active.length,
                              shrinkWrap: true,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: AppColors.primaryLightTrack,
                              ),
                              itemBuilder: (context, i) {
                                return NotificationTile(
                                  item: active[i],
                                  fromTeacher: true,
                                );
                              },
                            ),
                          ),

                        if (pending.isEmpty)
                          EmptyNotificationsState()
                        else
                          RefreshIndicator(
                            onRefresh: () async {
                              BlocProvider.of<NotificationsBloc>(
                                context,
                              ).add(GetNotificationsEvent());
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: pending.length,
                              shrinkWrap: true,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: AppColors.primaryLightTrack,
                              ),
                              itemBuilder: (context, i) {
                                return NotificationTile(
                                  item: pending[i],
                                  fromTeacher: true,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
