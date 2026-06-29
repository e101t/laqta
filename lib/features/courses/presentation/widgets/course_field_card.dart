import 'package:flutter/material.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';

/// Dark "luxury" form field wrapper, mirroring the private `_FieldCard`
/// pattern in venue_booking_screen.dart, shared across the courses feature's
/// own forms (editor, checkout).
class CourseFieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const CourseFieldCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return LaqtaLuxurySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
