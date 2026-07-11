import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/magic_handwriting_screen.dart';
import 'screens/history_screen.dart';
import 'screens/ai_model_config_screen.dart';
import 'models/note.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MagicNoteApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MagicNoteApp extends StatelessWidget {
  const MagicNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '魔法笔记',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39FF14),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0a1510),
        cardColor: const Color(0xFF0d1a0d),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      _notes = notesJson.map((json) => Note.fromJsonString(json)).toList();
    });
  }

  Future<void> _saveNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.insert(0, note);
    });
    final notesJson = _notes.map((n) => n.toJsonString()).toList();
    await prefs.setStringList('notes', notesJson);
  }

  Future<void> _deleteNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.removeAt(index);
    });
    final notesJson = _notes.map((n) => n.toJsonString()).toList();
    await prefs.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MagicHandwritingScreen(onNoteSaved: _saveNote),
          HistoryScreen(notes: _notes, onDelete: _deleteNote),
          const AIModelConfigScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF64FFDA).withOpacity(0.08),
            ],
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF64FFDA).withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note, color: Color(0xFF39FF14)),
              label: '书写',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: Color(0xFF39FF14)),
              label: '记录',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF39FF14)),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
