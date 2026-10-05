import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/norifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/build_context.dart';
import '../widgets/empty_notifications.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotificationsBloc>(context).add(GetNotificationsEvent());
  }

  void _onBack() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: "الإشعارات", onBackTap: _onBack),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<NotificationsBloc>(
                context,
              ).add(GetNotificationsEvent());
            },
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                return state.getNotificationsStatus.isLoading
                    ? Center(child: CoursatyAppLoader())
                    : state.notifications.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.notifications.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppColors.primaryLightTrack,
                        ),
                        itemBuilder: (context, i) {
                          return NotificationTile(
                            item: state.notifications[i],
                            fromTeacher: false,
                          );
                        },
                      )
                    : EmptyNotificationsState();
              },
            ),
          ),
        ),
      ),
    );
  }
}
