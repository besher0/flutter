import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../courses/data/model/lecture_details_model.dart';

Future<Segment?> showUpsertSegmentDialog(
  BuildContext context, {
  Segment? initialSegment,
}) async {
  return showDialog<Segment>(
    context: context,
    barrierDismissible: true,
    builder: (_) => UpsertSegmentDialog(initialSegment: initialSegment),
  );
}

class UpsertSegmentDialog extends StatefulWidget {
  final Segment? initialSegment;

  const UpsertSegmentDialog({super.key, this.initialSegment});

  @override
  State<UpsertSegmentDialog> createState() => _UpsertSegmentDialogState();
}

class _UpsertSegmentDialogState extends State<UpsertSegmentDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  // late final TextEditingController _endController;
  late final TextEditingController _sortOrderController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialSegment?.segmentName ?? '',
    );

    _startController = TextEditingController(
      text: _secondsToTimeString(widget.initialSegment?.startSeconds ?? 0),
    );

    // _endController = TextEditingController(
    //   text: _secondsToTimeString(
    //     widget.initialSegment?.endSeconds ?? 0,
    //   ),
    // );

    _sortOrderController = TextEditingController(
      text: widget.initialSegment?.sortOrder?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    // _endController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  String _secondsToTimeString(int seconds) {
    final duration = Duration(seconds: seconds);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    return [
      hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      secs.toString().padLeft(2, '0'),
    ].join(':');
  }

  int? _timeStringToSeconds(String value) {
    try {
      final parts = value.split(':');

      if (parts.length != 3) {
        return null;
      }

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);

      return (hours * 3600) + (minutes * 60) + seconds;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final currentSeconds = _timeStringToSeconds(controller.text) ?? 0;

    final currentDuration = Duration(seconds: currentSeconds);

    int hours = currentDuration.inHours;
    int minutes = currentDuration.inMinutes.remainder(60);
    int seconds = currentDuration.inSeconds.remainder(60);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('اختر الوقت'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: hours,
                        isExpanded: true,
                        items: List.generate(
                          24,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(index.toString().padLeft(2, '0')),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            hours = value ?? 0;
                          });
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(':'),
                    ),
                    Expanded(
                      child: DropdownButton<int>(
                        value: minutes,
                        isExpanded: true,
                        items: List.generate(
                          60,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(index.toString().padLeft(2, '0')),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            minutes = value ?? 0;
                          });
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(':'),
                    ),
                    Expanded(
                      child: DropdownButton<int>(
                        value: seconds,
                        isExpanded: true,
                        items: List.generate(
                          60,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(index.toString().padLeft(2, '0')),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            seconds = value ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final duration = Duration(
                  hours: hours,
                  minutes: minutes,
                  seconds: seconds,
                );

                controller.text = _secondsToTimeString(duration.inSeconds);

                Navigator.pop(context);
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startSeconds = _timeStringToSeconds(_startController.text);

    // final endSeconds =
    // _timeStringToSeconds(
    //   _endController.text,
    // );

    if (startSeconds == null) {
      return;
    }

    // if (endSeconds != null && endSeconds != 0 && endSeconds <= startSeconds) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'وقت النهاية يجب أن يكون أكبر من البداية',
    //       ),
    //     ),
    //   );
    //   return;
    // }

    Navigator.pop(
      context,
      Segment(
        id: widget.initialSegment?.id,
        videoId: widget.initialSegment?.videoId,
        createdAt: widget.initialSegment?.createdAt,
        segmentName: _nameController.text.trim(),
        startSeconds: startSeconds,
        // endSeconds: endSeconds,
        sortOrder: _sortOrderController.text.trim().isEmpty
            ? null
            : int.parse(_sortOrderController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSegment != null;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Text(
                    isEditing ? "تعديل المقطع" : "إضافة مقطع",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'اسم المقطع'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الاسم مطلوب';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _startController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'وقت البداية',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _pickTime(_startController);
                        },
                        icon: const Icon(Icons.access_time),
                      ),
                    ),
                    onTap: () {
                      _pickTime(_startController);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'وقت البداية مطلوب';
                      }

                      if (_timeStringToSeconds(value) == null) {
                        return 'تنسيق الوقت غير صحيح';
                      }

                      return null;
                    },
                  ),

                  // const SizedBox(height: 16),
                  //
                  // TextFormField(
                  //   controller: _endController,
                  //   readOnly: true,
                  //   decoration: InputDecoration(
                  //     labelText: 'وقت النهاية',
                  //     suffixIcon: IconButton(
                  //       onPressed: () {
                  //         _pickTime(
                  //           _endController,
                  //         );
                  //       },
                  //       icon: const Icon(
                  //         Icons.access_time,
                  //       ),
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     _pickTime(_endController);
                  //   },
                  //   validator: (value) {
                  //     // if (value == null ||
                  //     //     value.isEmpty) {
                  //     //   return 'وقت النهاية مطلوب';
                  //     // }
                  //     if(value != null) {
                  //       if (_timeStringToSeconds(
                  //           value) ==
                  //           null) {
                  //         return 'تنسيق الوقت غير صحيح';
                  //       }
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الترتيب (اختياري)',
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
