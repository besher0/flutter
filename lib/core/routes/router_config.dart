class RouterConfiguration {
  RouterConfiguration.init();

  final String kRootRoute = '/';
  final applicationRoutes = _ApplicationRoutes();
}

class _ApplicationRoutes {
  final String splash = '/';
  final String onboarding = '/onboarding';
  final String login = '/login';
  final String signup = '/signup';
  final String signupSuccess = '/signup_success';
  final String home = '/home';
  final String courses = '/courses';
  final String coursesBySubject = '/courses-by-subject';
  final String search = '/search';
  final String addCourse = '/add-course';
  final String notifications = '/notifications';
  final String addNotification = '/addNotification';
  final String subscriptions = '/subscriptions';
  final String contactUs = '/contact_us';
  final String customerService = '/customer_service';
  final String downloads = '/downloads';
  final String allPrograms = '/allPrograms';
  final String aboutApp = '/about_app';
  final String editProfile = '/edit_profile';
  final String changePassword = '/change_password';
  final String selectSubject = '/select_subject';
  final String changeUniversity = '/change_university';
  final String courseDetails = '/course_details';
  final String teacherCourseDetails = '/teacher_course_details';
  final String lectureDetails = '/lecture_details';
  final String lectureDetailsForTeacher = '/lecture_details_for_teacher';
  final String videoDetails = '/video_details';
  final String mcqQuestions = '/mcq_questions';
  final String materials = '/materials';
  final String pointsOfSale = '/points_of_sale';
  final String blockedAccount = '/blocked_account';
  final String teachers = '/teachers';
  final String pointOfSaleDetails = '/point_of_sale_details';
  final String teacherDetails = '/teacher_details';
  final String downloadedLectureDetails = '/downloaded_lecture_details';
  final String downloadedCourseDetails = '/downloaded_course_details';
}
