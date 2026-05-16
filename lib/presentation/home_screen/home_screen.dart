import 'dart:ui';

import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/note_section_header_widget.dart';
import './widgets/quick_capture_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  List<NoteModel> _allNotes = [];
  List<NoteModel> _filteredNotes = [];
  String _selectedSubject = 'All';
  bool _isLoading = true;
  int _selectedNavIndex = 0;
  bool _isCategoryView = false;
  final TextEditingController _quickCaptureController = TextEditingController();
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fabScaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOutCubic),
    );
    _loadNotes();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _quickCaptureController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await _db.getAllNotes();
    if (mounted) {
      setState(() {
        _allNotes = notes;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedSubject == 'All') {
      _filteredNotes = List.from(_allNotes);
    } else {
      _filteredNotes = _allNotes
          .where((n) => n.subject == _selectedSubject)
          .toList();
    }
  }

  List<String> get _subjects {
    final subjects = _allNotes.map((n) => n.subject).toSet().toList();
    subjects.sort();
    return subjects;
  }

  Map<String, List<NoteModel>> get _groupedByDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<NoteModel>>{};
    for (final note in _filteredNotes) {
      final noteDate = DateTime(
        note.updatedAt.year,
        note.updatedAt.month,
        note.updatedAt.day,
      );
      String group;
      if (noteDate == today) {
        group = 'Today';
      } else if (noteDate == yesterday) {
        group = 'Yesterday';
      } else if (noteDate.isAfter(weekAgo)) {
        group = 'This Week';
      } else {
        group = 'Older';
      }
      groups.putIfAbsent(group, () => []).add(note);
    }
    return groups;
  }

  Map<String, List<NoteModel>> get _groupedBySubject {
    final groups = <String, List<NoteModel>>{};
    for (final note in _filteredNotes) {
      groups.putIfAbsent(note.subject, () => []).add(note);
    }
    return groups;
  }

  void _onSubjectSelected(String subject) {
    setState(() {
      _selectedSubject = subject;
      _applyFilter();
    });
  }

  void _navigateToCreate() {
    Navigator.pushNamed(
      context,
      AppRoutes.noteFormScreen,
    ).then((_) => _loadNotes());
  }

  void _navigateToDetail(NoteModel note) {
    Navigator.pushNamed(
      context,
      AppRoutes.noteDetailScreen,
      arguments: note,
    ).then((_) => _loadNotes());
  }

  void _navigateToSearch() {
    setState(() => _selectedNavIndex = 1);
    Navigator.pushNamed(context, AppRoutes.searchScreen).then((_) {
      if (mounted) setState(() => _selectedNavIndex = 0);
      _loadNotes();
    });
  }

  Future<void> _handleQuickCapture() async {
    final text = _quickCaptureController.text.trim();
    if (text.isEmpty) return;
    final note = NoteModel(
      title: text,
      subject: 'General',
      content: '',
      colorHex: '#7C6AFA',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.insertNote(note);
    _quickCaptureController.clear();
    HapticFeedback.lightImpact();
    await _loadNotes();
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateGroups = _groupedByDate;
    final subjectGroups = _groupedBySubject;
    final dateGroupOrder = ['Today', 'Yesterday', 'This Week', 'Older'];
    final subjectGroupOrder = subjectGroups.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBarWidget(noteCount: _allNotes.length),
            const SizedBox(height: 10),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search notes...',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your Notes!',
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // View toggle button
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isCategoryView = !_isCategoryView),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _isCategoryView
                            ? theme.colorScheme.primary.withAlpha(46)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isCategoryView
                              ? theme.colorScheme.primary.withAlpha(120)
                              : Colors.white.withAlpha(20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCategoryView
                                ? Icons.category_rounded
                                : Icons.view_list_rounded,
                            size: 16,
                            color: _isCategoryView
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isCategoryView ? 'By Subject' : 'By Date',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isCategoryView
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilterChipsWidget(
              subjects: _subjects,
              selectedSubject: _selectedSubject,
              noteCounts: {
                'All': _allNotes.length,
                for (final s in _subjects)
                  s: _allNotes.where((n) => n.subject == s).length,
              },
              onSubjectSelected: _onSubjectSelected,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const SizedBox.shrink()
                  : _filteredNotes.isEmpty
                  ? EmptyStateWidget(
                      iconName: 'notes',
                      title: 'No notes yet',
                      subtitle: _selectedSubject == 'All'
                          ? 'Tap the + button to capture your first class note.'
                          : 'No notes found for $_selectedSubject.',
                      ctaLabel: 'Create Note',
                      onCta: _navigateToCreate,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotes,
                      color: theme.colorScheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: _isCategoryView
                          ? (_isTablet
                                ? _buildTabletCategoryGrid(
                                    subjectGroups,
                                    subjectGroupOrder,
                                  )
                                : _buildCategoryList(
                                    subjectGroups,
                                    subjectGroupOrder,
                                  ))
                          : (_isTablet
                                ? _buildTabletGrid(dateGroups, dateGroupOrder)
                                : _buildPhoneList(dateGroups, dateGroupOrder)),
                    ),
            ),
            QuickCaptureBarWidget(
              controller: _quickCaptureController,
              onSend: _handleQuickCapture,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildLiquidGlassNav(theme),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: GestureDetector(
          onTapDown: (_) => _fabAnimController.forward(),
          onTapUp: (_) {
            _fabAnimController.reverse();
            _navigateToCreate();
          },
          onTapCancel: () => _fabAnimController.reverse(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(115),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildPhoneList(
    Map<String, List<NoteModel>> groups,
    List<String> order,
  ) {
    final items = <Widget>[];
    for (final group in order) {
      if (!groups.containsKey(group)) continue;
      items.add(
        NoteSectionHeaderWidget(title: group, count: groups[group]!.length),
      );
      for (int i = 0; i < groups[group]!.length; i++) {
        final note = groups[group]![i];
        items.add(
          _AnimatedNoteCard(
            note: note,
            index: i,
            onTap: () => _navigateToDetail(note),
            onDelete: () async {
              await _db.deleteNote(note.id!);
              _loadNotes();
            },
          ),
        );
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildCategoryList(
    Map<String, List<NoteModel>> groups,
    List<String> order,
  ) {
    final items = <Widget>[];
    for (final subject in order) {
      if (!groups.containsKey(subject)) continue;
      items.add(
        _SubjectSectionHeader(subject: subject, count: groups[subject]!.length),
      );
      for (int i = 0; i < groups[subject]!.length; i++) {
        final note = groups[subject]![i];
        items.add(
          _AnimatedNoteCard(
            note: note,
            index: i,
            onTap: () => _navigateToDetail(note),
            onDelete: () async {
              await _db.deleteNote(note.id!);
              _loadNotes();
            },
          ),
        );
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildTabletGrid(
    Map<String, List<NoteModel>> groups,
    List<String> order,
  ) {
    final items = <Widget>[];
    for (final group in order) {
      if (!groups.containsKey(group)) continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
          child: NoteSectionHeaderWidget(
            title: group,
            count: groups[group]!.length,
          ),
        ),
      );
      final notes = groups[group]!;
      for (int i = 0; i < notes.length; i += 2) {
        items.add(
          Row(
            children: [
              Expanded(
                child: _AnimatedNoteCard(
                  note: notes[i],
                  index: i,
                  onTap: () => _navigateToDetail(notes[i]),
                  onDelete: () async {
                    await _db.deleteNote(notes[i].id!);
                    _loadNotes();
                  },
                ),
              ),
              if (i + 1 < notes.length)
                Expanded(
                  child: _AnimatedNoteCard(
                    note: notes[i + 1],
                    index: i + 1,
                    onTap: () => _navigateToDetail(notes[i + 1]),
                    onDelete: () async {
                      await _db.deleteNote(notes[i + 1].id!);
                      _loadNotes();
                    },
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildTabletCategoryGrid(
    Map<String, List<NoteModel>> groups,
    List<String> order,
  ) {
    final items = <Widget>[];
    for (final subject in order) {
      if (!groups.containsKey(subject)) continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
          child: _SubjectSectionHeader(
            subject: subject,
            count: groups[subject]!.length,
          ),
        ),
      );
      final notes = groups[subject]!;
      for (int i = 0; i < notes.length; i += 2) {
        items.add(
          Row(
            children: [
              Expanded(
                child: _AnimatedNoteCard(
                  note: notes[i],
                  index: i,
                  onTap: () => _navigateToDetail(notes[i]),
                  onDelete: () async {
                    await _db.deleteNote(notes[i].id!);
                    _loadNotes();
                  },
                ),
              ),
              if (i + 1 < notes.length)
                Expanded(
                  child: _AnimatedNoteCard(
                    note: notes[i + 1],
                    index: i + 1,
                    onTap: () => _navigateToDetail(notes[i + 1]),
                    onDelete: () async {
                      await _db.deleteNote(notes[i + 1].id!);
                      _loadNotes();
                    },
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, i) => const NoteCardSkeletonWidget(),
    );
  }

  Widget _buildLiquidGlassNav(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariantDark.withAlpha(191),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withAlpha(26), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  iconName: 'home',
                  iconOutlined: 'home_outlined',
                  label: 'Notes',
                  isActive: _selectedNavIndex == 0,
                  onTap: () => setState(() => _selectedNavIndex = 0),
                ),
                _NavItem(
                  iconName: 'search',
                  iconOutlined: 'search',
                  label: 'Search',
                  isActive: _selectedNavIndex == 1,
                  onTap: _navigateToSearch,
                ),
                const SizedBox(width: 60), // FAB space
                _NavItem(
                  iconName: 'category',
                  iconOutlined: 'category_outlined',
                  label: 'By Subject',
                  isActive: _isCategoryView,
                  onTap: () =>
                      setState(() => _isCategoryView = !_isCategoryView),
                ),
                _NavItem(
                  iconName: 'add_circle',
                  iconOutlined: 'add_circle_outline',
                  label: 'Add Note',
                  isActive: _selectedNavIndex == 3,
                  onTap: () {
                    setState(() => _selectedNavIndex = 3);
                    _navigateToCreate();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectSectionHeader extends StatelessWidget {
  final String subject;
  final int count;

  const _SubjectSectionHeader({required this.subject, required this.count});

  Color _subjectColor(String subject) {
    final colors = {
      'Mathematics': const Color(0xFF7C6AFA),
      'Physics': const Color(0xFF38BDF8),
      'Chemistry': const Color(0xFF22C55E),
      'Biology': const Color(0xFFF59E0B),
      'History': const Color(0xFFF97316),
      'Computer Science': const Color(0xFF06B6D4),
      'Literature': const Color(0xFFEC4899),
      'Economics': const Color(0xFF94A3B8),
      'Geography': const Color(0xFF10B981),
      'Philosophy': const Color(0xFFA78BFA),
      'General': const Color(0xFF64748B),
    };
    return colors[subject] ?? const Color(0xFF7C6AFA);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _subjectColor(subject);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            subject,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconName;
  final String iconOutlined;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconName,
    required this.iconOutlined,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(46),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: isActive ? iconName : iconOutlined,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNoteCard extends StatefulWidget {
  final NoteModel note;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AnimatedNoteCard({
    required this.note,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_AnimatedNoteCard> createState() => _AnimatedNoteCardState();
}

class _AnimatedNoteCardState extends State<_AnimatedNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + (widget.index * 60).clamp(0, 400)),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: Key('note-${widget.note.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete_rounded,
              color: AppTheme.error,
              size: 24,
            ),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.surfaceDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Delete Note',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    content: Text(
                      'This note will be permanently deleted.',
                      style: GoogleFonts.manrope(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.manrope(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          'Delete',
                          style: GoogleFonts.manrope(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) => widget.onDelete(),
          child: NoteCardWidget(note: widget.note, onTap: widget.onTap),
        ),
      ),
    );
  }
}
