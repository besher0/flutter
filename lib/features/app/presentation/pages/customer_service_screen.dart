import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({
    super.key,
    required this.contact,
    required this.technical,
  });

  final String contact, technical;

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  Widget _numberCard({
    required Color borderColor,
    required Color titleColor,
    required String title,
    required String number,
  }) {
    return InkWell(
      onTap: () {
        HelperFunctions.openCallApp(number);
      },
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            const BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.contact_phone, color: borderColor, size: 38),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      number,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      'تواصل معنا',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 28),
                if (widget.technical != 'null')
                  _numberCard(
                    borderColor: AppColors.primaryLightTrackBorder,
                    titleColor: Theme.of(context).colorScheme.primary,
                    title: 'رقم الدعم الفني',
                    number: widget.technical,
                  ),
                const SizedBox(height: 14),
                if (widget.contact != 'null')
                  _numberCard(
                    borderColor: AppColors.secondaryActive,
                    titleColor: AppColors.secondary,
                    title: 'رقم الدعم الفني',
                    number: widget.contact,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
