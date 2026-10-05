import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Search field with filter button. Matches Figma Pass (124:4913–124:4928).
class SearchWithFilterBar extends StatelessWidget {
  const SearchWithFilterBar({
    super.key,
    this.hint = 'ابحث عن أي شيئ تريده...',
    required this.controller,
  });

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CoursatyTextField(
        hint: hint,
        minLines: 1,
        controller: controller,
        onFieldSubmitted: (query) {
          search(query, context, passCheckLength: true);
        },
        onChanged: (query) {
          search(query, context);
        },
        suffixIcon: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
          child: SvgPicture.asset(
            AppAssets.iconMagnifyingGlass,
            height: 15,
            color: AppColors.greyNormal,
          ),
        ),
      ),
    );
  }

  void search(
    String query,
    BuildContext context, {
    bool passCheckLength = false,
  }) {
    if (query.length > 3 || passCheckLength) {
      BlocProvider.of<HomeBloc>(
        context,
      ).add(SearchEvent(query: query, reset: true));
    } else if (query.isEmpty) {
      BlocProvider.of<HomeBloc>(
        context,
      ).add(SearchEvent(query: '', reset: true));
    }
  }
}
