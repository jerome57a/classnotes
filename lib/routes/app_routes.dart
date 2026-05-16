import 'package:flutter/material.dart';

import '../presentation/home_screen/home_screen.dart';
import '../presentation/note_detail_screen/note_detail_screen.dart';
import '../presentation/note_form_screen/note_form_screen.dart';
import '../presentation/search_screen/search_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String noteFormScreen = '/note-form-screen';
  static const String noteDetailScreen = '/note-detail-screen';
  static const String searchScreen = '/search-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const HomeScreen(),
    homeScreen: (context) => const HomeScreen(),
    noteFormScreen: (context) => const NoteFormScreen(),
    noteDetailScreen: (context) => const NoteDetailScreen(),
    searchScreen: (context) => const SearchScreen(),
  };
}
