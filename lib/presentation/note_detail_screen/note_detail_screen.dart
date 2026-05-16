// lib/presentation/note_detail_screen/note_detail_screen.dart
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import './widgets/detail_app_bar_widget.dart';
import './widgets/note_body_widget.dart';
import './widgets/note_inline_toolbar_widget.dart';
import './widgets/note_title_widget.dart';
import './widgets/related_notes_widget.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  NoteModel? _note;
  List<NoteModel> _relatedNotes = [];
  bool _isLoading = true;

  late AnimationController _entranceController;
  late Animation<double> _titleFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is NoteModel) {
      // Allow dynamic swapping even if route replaces context entries directly
      if (_note == null || _note!.id != args.id) {
        _note = args;
        _isLoading = true;
        _loadRelatedNotes();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadRelatedNotes() async {
    if (_note == null) return;
    final all = await _db.getAllNotes();
    if (mounted) {
      setState(() {
        _relatedNotes = all
            .where((n) => n.subject.toLowerCase() == _note!.subject.toLowerCase() && n.id != _note!.id)
            .take(3)
            .toList();
        _isLoading = false;
      });
      _entranceController.forward(from: 0.0);
    }
  }

  void _navigateToEdit() {
    if (_note == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.noteFormScreen,
      arguments: _note,
    ).then((_) async {
      if (_note?.id != null) {
        final updated = await _db.getNoteById(_note!.id!);
        if (updated != null && mounted) {
          setState(() {
            _note = updated;
          });
          _loadRelatedNotes();
        }
      }
    });
  }

  Future<void> _deleteNote() async {
    if (_note == null || _note!.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Note',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${_note?.title}"? This cannot be undone.',
          style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.manrope(color: AppTheme.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _db.deleteNote(_note!.id!);
      HapticFeedback.mediumImpact();
      Fluttertoast.showToast(
        msg: 'Note deleted',
        backgroundColor: AppTheme.surfaceVariantDark,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    }
  }

  void _shareNote() {
    if (_note == null) return;
    final text = '${_note!.title}\n${_note!.subject}\n\n${_note!.content}';
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: 'Note copied to clipboard',
      backgroundColor: AppTheme.success,
      textColor: Colors.white,
    );
  }

  Color get _accentColor {
    if (_note == null) return AppTheme.primary;
    try {
      final hex = _note!.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: DetailAppBarWidget(
        note: _note!,
        onBack: () => Navigator.pop(context),
        onShare: _shareNote,
        accentColor: _accentColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: isTablet
                  ? Center(child: SizedBox(width: 680, child: _buildBody(theme)))
                  : _buildBody(theme),
            ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _titleFade,
            child: NoteTitleWidget(note: _note!, accentColor: _accentColor),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: NoteBodyWidget(note: _note!),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _contentFade,
            child: NoteInlineToolbarWidget(
              onEdit: _navigateToEdit,
              onDelete: _deleteNote,
              onShare: _shareNote,
              accentColor: _accentColor,
            ),
          ),
        ),
        if (_relatedNotes.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFade,
              child: RelatedNotesWidget(
                notes: _relatedNotes,
                onNoteTap: (note) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.noteDetailScreen,
                    arguments: note,
                  );
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}