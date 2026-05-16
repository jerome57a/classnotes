import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import './widgets/color_picker_widget.dart';
import './widgets/form_field_widget.dart';
import './widgets/subject_dropdown_widget.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedSubject = 'Mathematics';
  String _selectedColorHex = '#7C6AFA';
  bool _isSaving = false;
  bool _isEditMode = false;
  NoteModel? _existingNote;

  // Search mode
  bool _isSearchMode = false;
  final _searchController = TextEditingController();
  List<NoteModel> _searchResults = [];
  bool _isSearching = false;

  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  static const List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Literature',
    'Computer Science',
    'Economics',
    'Geography',
    'Philosophy',
    'General',
  ];

  static const List<String> _colorOptions = [
    '#7C6AFA',
    '#38BDF8',
    '#22C55E',
    '#F59E0B',
    '#F97316',
    '#EC4899',
    '#06B6D4',
    '#94A3B8',
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is NoteModel && !_isEditMode) {
      _isEditMode = true;
      _existingNote = args;
      _titleController.text = args.title;
      _selectedSubject = args.subject;
      _contentController.text = args.content;
      _selectedColorHex = args.colorHex;
    } else if (args is Map && args['mode'] == 'search') {
      _isSearchMode = true;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      if (_isEditMode && _existingNote != null) {
        final updated = _existingNote!.copyWith(
          title: _titleController.text.trim(),
          subject: _selectedSubject,
          content: _contentController.text.trim(),
          colorHex: _selectedColorHex,
          updatedAt: DateTime.now(),
        );
        // TODO: Replace with repository layer for production
        await _db.updateNote(updated);
        Fluttertoast.showToast(
          msg: 'Note updated!',
          backgroundColor: AppTheme.success,
          textColor: Colors.white,
        );
      } else {
        final note = NoteModel(
          title: _titleController.text.trim(),
          subject: _selectedSubject,
          content: _contentController.text.trim(),
          colorHex: _selectedColorHex,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _db.insertNote(note);
        Fluttertoast.showToast(
          msg: 'Note saved!',
          backgroundColor: AppTheme.success,
          textColor: Colors.white,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Couldn\'t save note. Please try again.',
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    // TODO: Replace with repository layer for production
    final results = await _db.searchNotes(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    if (_isSearchMode) return _buildSearchScreen();
    return _buildFormScreen();
  }

  Widget _buildFormScreen() {
    final theme = Theme.of(context);
    final content = FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: _isTablet ? 0 : 20,
              vertical: 8,
            ),
            children: [
              // Title field
              FormFieldWidget(
                controller: _titleController,
                label: 'Note Title',
                hint: 'e.g. Calculus — Limits & Continuity',
                iconName: 'note',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              // Subject dropdown
              SubjectDropdownWidget(
                subjects: _subjects,
                selectedSubject: _selectedSubject,
                onChanged: (s) => setState(() => _selectedSubject = s!),
              ),
              const SizedBox(height: 16),
              // Content field
              FormFieldWidget(
                controller: _contentController,
                label: 'Content',
                hint: 'Write your lecture notes here…',
                iconName: 'notes',
                maxLines: 10,
                minLines: 6,
                validator: null,
              ),
              const SizedBox(height: 20),
              // Color picker
              ColorPickerWidget(
                colorOptions: _colorOptions,
                selectedColor: _selectedColorHex,
                onColorSelected: (c) => setState(() => _selectedColorHex = c),
              ),
              const SizedBox(height: 32),
              // Save button
              _buildSaveButton(theme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildFormAppBar(theme),
      body: SafeArea(
        child: _isTablet
            ? Center(child: SizedBox(width: 560, child: content))
            : content,
      ),
    );
  }

  PreferredSizeWidget _buildFormAppBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: AppTheme.backgroundDark.withAlpha(191),
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              _isEditMode ? 'Edit Note' : 'New Note',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              if (_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.error.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Discard',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(89),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _saveNote,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withAlpha(38),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isEditMode ? 'Update Note' : 'Save Note',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              backgroundColor: AppTheme.backgroundDark.withAlpha(191),
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                ),
              ),
              title: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withAlpha(20),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search notes, subjects, content…',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      color: theme.colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 6),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.outline,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _searchController.text.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'search',
                      color: theme.colorScheme.outline.withAlpha(102),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search your notes',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search by title, subject, or content',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: theme.colorScheme.outline.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              )
            : _isSearching
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _searchResults.isEmpty
            ? EmptyStateWidget(
                iconName: 'search',
                title: 'No results found',
                subtitle:
                    'No notes match "${_searchController.text}". Try different keywords.',
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (_, i) {
                  final note = _searchResults[i];
                  return _SearchResultCard(
                    note: note,
                    query: _searchController.text,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.noteDetailScreen,
                        arguments: note,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final NoteModel note;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.note,
    required this.query,
    required this.onTap,
  });

  Color get _accent {
    try {
      final hex = note.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(18), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadgeWidget(
                        label: note.subject,
                        color: _accent,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
