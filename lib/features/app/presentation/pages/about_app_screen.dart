import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/app/presentation/bloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/constant/design/app_assets.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final String about = r"""
  • صُمم تطبيق كورساتي بشكل مدروس ليكون رفيقك الأكاديمي المتكامل خلال مراحل دراستك الجامعية المختلفة؛ للارتقاء بمستواك العلمي، وتحضيرك للدخول في سوق العمل لاحقاً. 💼

• نحن في كورساتي نؤمن بأن النجاح الجامعي لا يعتمد فقط على المجهود الفردي للطالب، بل على توفر بيئة تعليمية منظمة وغنية بالموارد، قادرة على ربطه بالمصادر والأدوات التعليمية الفعالة اللازمة للتفوق الأكاديمي بأسلوب سهل وممتع. ✨

• لذلك، جمعنا في منصة واحدة كل ما يحتاجه الطالب للوصول لهذا الهدف، والتي تشمل:

1️⃣ مقاطع فيديو بجودة عالية تشرح المواد العلمية. 🎥
2️⃣ ملفات PDF داعمة، واختبارات ذكية تقيس الفهم. 📝
3️⃣ قنوات تواصل منظمة مع المدرسين لمتابعة التقدم ومعالجة الإشكالات الأكاديمية في الوقت المناسب، والكثير.. 💬

🎯 طموحاتنا ورؤيتنا :
 نطمح في كورساتي بأن يكون هذا التطبيق المرجع الأكاديمي الرقمي الأبرز للطالب الجامعي، والذي يغطي جميع الجامعات السورية بمحتوى محدّث ومنظّم، وبأعلى معايير الجودة التعليمية.

• هدفنا هو ردم الفجوة وسلبيات التعلم التقليدي بين القاعة الدراسية الرتيبة والتعلم الذاتي غير المنظم والمليء بالمشتتات ؛ وذلك من خلال توحيد هذه المصادر ضمن سياق واحد، وتوفير تجربة تتيح لكل طالب -بغض النظر عن كليته أو مستواه العلمي- الوصول إلى المصادر العلمية التي يحتاجها، والاستعداد التام للامتحانات. 🚀

💡 ما يميز المنصة ؟

محتوى أكاديمي متنوع يشمل :
1️⃣ مقاطع فيديو وملفات مرجعية: مرتبة وشاملة، ومصنفة بدقة حسب المنهج الجامعي. 📚
2️⃣ تقييم ذاتي ذكي: اختبارات تفاعلية بعد كل محاضرة لقياس الاستيعاب، مع تحليل فوري يوضح نقاط القوة ومواطن التحسين. 📊
3️⃣ متابعة أكاديمية مستمرة: نظام تواصل منظم مع المدرسين لطرح الاستفسارات، مراجعة الواجبات، وتلقي الملاحظات البناءة. 🤝
4️⃣ بحث وفلاتر ذكية: يمكنك البحث عن مادة، أستاذ، أو دورة للوصول إلى النتيجة المطلوبة بسرعة وفاعلية، بالإضافة إلى فلترة متقدمة للكورسات حسب طلبك. 🔍

🛡 التزامنا تجاه الطالب الجامعي:
نلتزم بالجودة في إنتاج المحتوى، الشفافية الأكاديمية، وحماية خصوصية بياناتك. كما نعمل باستمرار على تطوير التطبيق بالاستماع لملاحظات الطلاب والأساتذة؛ لضمان توافق كل ميزة مع الواقع الدراسي ومتطلبات الاعتماد الجامعي. 🔐

انضم إلى مسيرة التفوق..
سواء كنت في عامك الأول، أو على وشك التخرج! 🥇
  """;

  @override
  Widget build(BuildContext context) {
    final isThemeLight = context.read<AppBloc>().state.isThemeLight;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: "حول التطبيق"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 110,
                  child: Center(
                    child: Image.asset(
                      isThemeLight ? AppAssets.logo : AppAssets.logoDark,
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'عن كورساتي',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D5A5B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  about,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
