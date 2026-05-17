import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/note_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<NoteModel> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _db.searchNotes(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.manrope(color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: GoogleFonts.manrope(color: Colors.black45),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _searchController.text.isEmpty
          ? Center(child: Text('Type to find notes', style: GoogleFonts.manrope(color: Colors.black54)))
          : _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Center(child: Text('No matches found', style: GoogleFonts.manrope(color: Colors.black54)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final note = _searchResults[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Text(note.title, style: GoogleFonts.manrope(color: Colors.black87, fontWeight: FontWeight.w600)),
                          subtitle: Text(note.subject, style: GoogleFonts.manrope(color: AppTheme.subjectColor(note.subject), fontWeight: FontWeight.w500)),
                          onTap: () {
                            // Unfocus keyboard before navigating
                            FocusScope.of(context).unfocus();
                            Navigator.pushNamed(context, AppRoutes.noteDetailScreen, arguments: note);
                          },
                        );
                      },
                    ),
    );
  }
}