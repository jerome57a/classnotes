import 'package:flutter/material.dart';
import '../../data/models/note_model.dart';
import './widgets/detail_app_bar_widget.dart';
import './widgets/note_body_widget.dart';
import './widgets/note_title_widget.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final note = ModalRoute.of(context)!.settings.arguments as NoteModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBarWidget(note: note),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoteTitleWidget(note: note),
              const SizedBox(height: 24),
              NoteBodyWidget(content: note.content),
            ],
          ),
        ),
      ),
    );
  }
}