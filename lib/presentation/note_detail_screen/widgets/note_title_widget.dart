import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';
import '../../../data/models/note_model.dart';

class NoteTitleWidget extends StatelessWidget {
  final NoteModel note;

  const NoteTitleWidget({super.key, required this.note});

  Color get _accentColor {
    try {
      final hex = note.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  String _formatFullDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatusBadgeWidget(label: note.subject, color: _accentColor, fontSize: 12),
            const Spacer(),
            Text(
              _formatFullDate(note.updatedAt),
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          note.title,
          style: GoogleFonts.manrope(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}