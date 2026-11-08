import 'package:coursaty_student_and_teacher/app/widgets/coursaty_text_field.dart';
import 'package:coursaty_student_and_teacher/core/utils/debouncer.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Search field with filter button. Matches Figma Pass (124:4913–124:4928).
///
/// Typing waits [searchDebounce] after the last letter before searching, so
/// one request goes out per pause instead of one per letter. The keyboard's
/// search key searches at once, and clearing the field resets at once. The
/// same query is never sent twice in a row.
class SearchWithFilterBar extends StatefulWidget {
  const SearchWithFilterBar({
    super.key,
    this.hint = 'ابحث عن أي شيئ تريده...',
    required this.controller,
  });

  /// Pause after the last keystroke before searching. 400 ms: on a phone the
  /// gap between letters is often 250–350 ms, so 300 ms still fired mid-word
  /// for many users; 400 ms still feels immediate.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Shorter queries are not searched while typing (the search key still
  /// searches them).
  static const int minQueryLength = 4;

  final String hint;
  final TextEditingController controller;

  @override
  State<SearchWithFilterBar> createState() => _SearchWithFilterBarState();
}

class _SearchWithFilterBarState extends State<SearchWithFilterBar> {
  final _debouncer = Debouncer(SearchWithFilterBar.searchDebounce);

  /// Last query sent, so a repeat (typing then deleting back) sends nothing.
  String? _lastSent;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _send(String query) {
    if (query == _lastSent) return;
    _lastSent = query;
    context.read<HomeBloc>().add(SearchEvent(query: query, reset: true));
  }

  void _onChanged(String raw) {
    final query = raw.trim();
    if (query.isEmpty) {
      _debouncer.cancel();
      _send('');
    } else if (query.length >= SearchWithFilterBar.minQueryLength) {
      _debouncer(() {
        if (mounted) _send(query);
      });
    } else {
      // Too short to search: drop a search still waiting for a longer query.
      _debouncer.cancel();
    }
  }

  void _onSubmitted(String raw) {
    _debouncer.cancel();
    final query = raw.trim();
    if (query.isNotEmpty) _send(query);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CoursatyTextField(
        hint: widget.hint,
        minLines: 1,
        controller: widget.controller,
        onFieldSubmitted: _onSubmitted,
        onChanged: _onChanged,
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
}
