import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/note_model.dart';
import '../../../theme/app_theme.dart';

class NoteBodyWidget extends StatelessWidget {
  final NoteModel note;

  const NoteBodyWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (note.content.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariantDark.withAlpha(102),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(15), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'No content yet. Tap edit to add notes.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Split into paragraphs for richer rendering
    final paragraphs = note.content
        .split('\n')
        .where((l) => l.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bold first paragraph (intro line — anatomy from Image 1 Screen 1.2)
          if (paragraphs.isNotEmpty) ...[
            Text(
              paragraphs.first,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
          ],
          // Remaining paragraphs — regular body
          ...paragraphs.skip(1).map((para) {
            // Detect bullet points
            if (para.trimLeft().startsWith('•') ||
                para.trimLeft().startsWith('-') ||
                para.trimLeft().startsWith('*')) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(179),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        para.replaceFirst(RegExp(r'^[\s•\-\*]+'), '').trim(),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color:
                              theme.colorScheme.bodyLarge?.color ??
                              theme.colorScheme.onSurface.withAlpha(217),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            // Detect numbered items
            if (RegExp(r'^\d+\.').hasMatch(para.trimLeft())) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  para,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withAlpha(230),
                    height: 1.65,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                para,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withAlpha(209),
                  height: 1.7,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // "Tap to continue" prompt — anatomy from Image 1 Screen 1.2
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tap edit to add more…',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on ColorScheme {
  TextStyle? get bodyLarge => null;
}
