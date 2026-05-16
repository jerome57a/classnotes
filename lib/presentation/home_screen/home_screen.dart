import 'dart:ui';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/note_section_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  List<NoteModel> _allNotes = [];
  List<NoteModel> _filteredNotes = [];
  String _selectedSubject = 'All';
  bool _isLoading = true;
  int _selectedNavIndex = 0;
  bool _isCategoryView = false;
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
          .where((n) => n.subject.toLowerCase() == _selectedSubject.toLowerCase())
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
    Navigator.pushNamed(context, AppRoutes.noteFormScreen).then((_) => _loadNotes());
  }

  void _navigateToDetail(NoteModel note) {
    Navigator.pushNamed(context, AppRoutes.noteDetailScreen, arguments: note).then((_) => _loadNotes());
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, AppRoutes.searchScreen).then((_) => _loadNotes());
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateGroups = _groupedByDate;
    final subjectGroups = _groupedBySubject;
    final dateGroupOrder = ['Today', 'Yesterday', 'This Week', 'Older'];
    
    // Fixed: Splitting toList() and sort() into two distinct lines
    final subjectGroupOrder = subjectGroups.keys.toList();
    subjectGroupOrder.sort();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBarWidget(noteCount: _allNotes.length),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withAlpha(15), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search_rounded, size: 20, color: Colors.black45),
                      const SizedBox(width: 10),
                      Text(
                        'Search notes...',
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your Notes',
                      style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, height: 1.2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isCategoryView = !_isCategoryView),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _isCategoryView ? theme.colorScheme.primary.withAlpha(30) : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _isCategoryView ? theme.colorScheme.primary.withAlpha(90) : Colors.black.withAlpha(15), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isCategoryView ? Icons.category_rounded : Icons.view_list_rounded, size: 16, color: _isCategoryView ? theme.colorScheme.primary : Colors.black54),
                          const SizedBox(width: 5),
                          Text(
                            _isCategoryView ? 'By Subject' : 'By Date',
                            style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: _isCategoryView ? theme.colorScheme.primary : Colors.black54),
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
                for (final s in _subjects) s: _allNotes.where((n) => n.subject == s).length,
              },
              onSubjectSelected: _onSubjectSelected,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? _buildSkeleton()
                  : _filteredNotes.isEmpty
                      ? EmptyStateWidget(
                          iconName: 'notes',
                          title: 'No notes yet',
                          subtitle: _selectedSubject == 'All' ? 'Tap the + button to capture your first note.' : 'No notes found for $_selectedSubject.',
                          ctaLabel: 'Create Note',
                          onCta: _navigateToCreate,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          color: theme.colorScheme.primary,
                          backgroundColor: Colors.white,
                          child: _isCategoryView
                              ? (_isTablet ? _buildTabletCategoryGrid(subjectGroups, subjectGroupOrder) : _buildCategoryList(subjectGroups, subjectGroupOrder))
                              : (_isTablet ? _buildTabletGrid(dateGroups, dateGroupOrder) : _buildPhoneList(dateGroups, dateGroupOrder)),
                        ),
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
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: theme.colorScheme.primary.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildPhoneList(Map<String, List<NoteModel>> groups, List<String> order) {
    final items = <Widget>[];
    for (final group in order) {
      if (!groups.containsKey(group) || groups[group]!.isEmpty) continue;
      items.add(NoteSectionHeaderWidget(title: group, count: groups[group]!.length));
      for (int i = 0; i < groups[group]!.length; i++) {
        final note = groups[group]![i];
        items.add(_AnimatedNoteCard(note: note, index: i, onTap: () => _navigateToDetail(note), onDelete: () async { if (note.id != null) { await _db.deleteNote(note.id!); _loadNotes(); } }));
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: items);
  }

  Widget _buildCategoryList(Map<String, List<NoteModel>> groups, List<String> order) {
    final items = <Widget>[];
    for (final subject in order) {
      if (!groups.containsKey(subject) || groups[subject]!.isEmpty) continue;
      items.add(_SubjectSectionHeader(subject: subject, count: groups[subject]!.length));
      for (int i = 0; i < groups[subject]!.length; i++) {
        final note = groups[subject]![i];
        items.add(_AnimatedNoteCard(note: note, index: i, onTap: () => _navigateToDetail(note), onDelete: () async { if (note.id != null) { await _db.deleteNote(note.id!); _loadNotes(); } }));
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: items);
  }

  Widget _buildTabletGrid(Map<String, List<NoteModel>> groups, List<String> order) {
    final items = <Widget>[];
    for (final group in order) {
      if (!groups.containsKey(group) || groups[group]!.isEmpty) continue;
      items.add(Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8), child: NoteSectionHeaderWidget(title: group, count: groups[group]!.length)));
      final notes = groups[group]!;
      for (int i = 0; i < notes.length; i += 2) {
        items.add(Row(children: [
          Expanded(child: _AnimatedNoteCard(note: notes[i], index: i, onTap: () => _navigateToDetail(notes[i]), onDelete: () async { if (notes[i].id != null) { await _db.deleteNote(notes[i].id!); _loadNotes(); } })),
          const SizedBox(width: 12),
          if (i + 1 < notes.length) Expanded(child: _AnimatedNoteCard(note: notes[i + 1], index: i + 1, onTap: () => _navigateToDetail(notes[i + 1]), onDelete: () async { if (notes[i + 1].id != null) { await _db.deleteNote(notes[i + 1].id!); _loadNotes(); } })) else const Expanded(child: SizedBox()),
        ]));
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: items);
  }

  Widget _buildTabletCategoryGrid(Map<String, List<NoteModel>> groups, List<String> order) {
    final items = <Widget>[];
    for (final subject in order) {
      if (!groups.containsKey(subject) || groups[subject]!.isEmpty) continue;
      items.add(Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8), child: _SubjectSectionHeader(subject: subject, count: groups[subject]!.length)));
      final notes = groups[subject]!;
      for (int i = 0; i < notes.length; i += 2) {
        items.add(Row(children: [
          Expanded(child: _AnimatedNoteCard(note: notes[i], index: i, onTap: () => _navigateToDetail(notes[i]), onDelete: () async { if (notes[i].id != null) { await _db.deleteNote(notes[i].id!); _loadNotes(); } })),
          const SizedBox(width: 12),
          if (i + 1 < notes.length) Expanded(child: _AnimatedNoteCard(note: notes[i + 1], index: i + 1, onTap: () => _navigateToDetail(notes[i + 1]), onDelete: () async { if (notes[i + 1].id != null) { await _db.deleteNote(notes[i + 1].id!); _loadNotes(); } })) else const Expanded(child: SizedBox()),
        ]));
      }
    }
    items.add(const SizedBox(height: 160));
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: items);
  }

  Widget _buildSkeleton() {
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: 5, itemBuilder: (_, i) => const NoteCardSkeletonWidget());
  }

  Widget _buildLiquidGlassNav(ThemeData theme) {
    return SizedBox(
      height: 88,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black.withAlpha(20), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    iconName: 'home',
                    iconOutlined: 'home_outlined',
                    label: 'Notes',
                    isActive: _selectedNavIndex == 0 && !_isCategoryView,
                    onTap: () => setState(() { _selectedNavIndex = 0; _isCategoryView = false; }),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    iconName: 'star',
                    iconOutlined: 'star_outline',
                    label: 'Favorites',
                    isActive: _selectedNavIndex == 1,
                    onTap: () => setState(() { _selectedNavIndex = 1; }),
                  ),
                ),
                const SizedBox(width: 68), 
                Expanded(
                  child: _NavItem(
                    iconName: 'category',
                    iconOutlined: 'category_outlined',
                    label: 'Subjects',
                    isActive: _isCategoryView,
                    onTap: () => setState(() { _isCategoryView = true; _selectedNavIndex = 2; }),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    iconName: 'add_circle',
                    iconOutlined: 'add_circle_outline',
                    label: 'Create',
                    isActive: _selectedNavIndex == 3,
                    onTap: _navigateToCreate,
                  ),
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

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColor(subject);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(subject, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withAlpha(38), borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
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

  const _NavItem({required this.iconName, required this.iconOutlined, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: isActive ? iconName : iconOutlined,
              color: isActive ? theme.colorScheme.primary : Colors.black45,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? theme.colorScheme.primary : Colors.black45),
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
  const _AnimatedNoteCard({required this.note, required this.index, required this.onTap, required this.onDelete});

  @override
  State<_AnimatedNoteCard> createState() => _AnimatedNoteCardState();
}

class _AnimatedNoteCardState extends State<_AnimatedNoteCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 350 + (widget.index * 60).clamp(0, 400)));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
            decoration: BoxDecoration(color: AppTheme.error.withAlpha(38), borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_rounded, color: AppTheme.error, size: 24),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Delete Note', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.black)),
                content: Text('This note will be permanently deleted.', style: GoogleFonts.manrope(color: Colors.black87)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.black54))),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: GoogleFonts.manrope(color: AppTheme.error, fontWeight: FontWeight.w600))),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) => widget.onDelete(),
          child: NoteCardWidget(note: widget.note, onTap: widget.onTap),
        ),
      ),
    );
  }
}