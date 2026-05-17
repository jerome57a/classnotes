import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteBodyWidget extends StatelessWidget {
  final String content;

  const NoteBodyWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content.isEmpty ? 'No content added yet.' : content,
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
        height: 1.6,
        letterSpacing: 0.3,
      ),
    );
  }
}