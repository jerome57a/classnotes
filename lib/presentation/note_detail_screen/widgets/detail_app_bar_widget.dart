import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/note_model.dart';

class DetailAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final NoteModel note;

  const DetailAppBarWidget({super.key, required this.note});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.black87),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.noteFormScreen, arguments: note).then((_) {
              Navigator.pop(context); 
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
          onPressed: () => _confirmDelete(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Note', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.black87)),
        content: Text('Are you sure you want to permanently delete this note?', style: GoogleFonts.manrope(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              if (note.id != null) {
                await DatabaseHelper().deleteNote(note.id!);
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: Text('Delete', style: GoogleFonts.manrope(color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}