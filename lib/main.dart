// main.dart - Complete Period Tracker App
// Part 1: Imports, Constants, and Main Setup

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

// ============================================
// MAIN FUNCTION AND APP
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize secure storage
  const secureStorage = FlutterSecureStorage();
  
  // Get encryption key
  final encryptionKeyString = await secureStorage.read(key: 'key');
  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }
  
  runApp(
    const ProviderScope(
      child: PeriodTrackerApp(),
    ),
  );
}

class PeriodTrackerApp extends ConsumerWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Period Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

// ============================================
// CONSTANTS
// ============================================

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFFF48FB1);
  static const Color lightSecondary = Color(0xFF81D4FA);
  static const Color lightBackground = Color(0xFFFFF8F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFE57373);
  
  // Dark Theme Colors with Sunflower
  static const Color darkPrimary = Color(0xFFFFD93D);
  static const Color darkSecondary = Color(0xFFFFA726);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkError = Color(0xFFCF6679);
  
  // Gradient Colors
  static const List<Color> splashGradient = [
    Color(0xFFFFDEE9),
    Color(0xFFB5FFFC),
  ];
  
  static const List<Color> buttonGradient = [
    Color(0xFFF48FB1),
    Color(0xFFCE93D8),
  ];
  
  // Calendar Colors
  static const Color periodColor = Color(0xFFF48FB1);
  static const Color ovulationColor = Color(0xFF81D4FA);
  static const Color fertilityColor = Color(0xFFC5E1A5);
  
  // Pastel Colors
  static const Color pastelPink = Color(0xFFF8BBD0);
  static const Color pastelBlue = Color(0xFFBBDEFB);
  static const Color pastelGreen = Color(0xFFC8E6C9);
  static const Color pastelYellow = Color(0xFFFFF9C4);
  static const Color pastelPurple = Color(0xFFE1BEE7);
}

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C2C2C),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF424242),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    ),
    cardTheme: CardThemeData(  // اصلاح شده از CardTheme به CardThemeData
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFE0E0E0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFE0E0E0),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    ),
    cardTheme: CardThemeData(  // اصلاح شده از CardTheme به CardThemeData
      elevation: 4,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
  );
}

// ============================================
// DOMAIN ENTITIES
// ============================================

class Period extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodLength;
  final List<String> symptoms;
  final String? notes;

  const Period({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodLength,
    this.symptoms = const [],
    this.notes,
  });

  DateTime get nextPeriodDate => startDate.add(Duration(days: cycleLength));
  DateTime get ovulationDate => startDate.add(Duration(days: cycleLength - 14));
  DateTime get fertilityWindowStart => ovulationDate.subtract(const Duration(days: 5));
  DateTime get fertilityWindowEnd => ovulationDate.add(const Duration(days: 1));

  @override
  List<Object?> get props => [
        id,
        startDate,
        endDate,
        cycleLength,
        periodLength,
        symptoms,
        notes,
      ];
}

class Note extends Equatable {
  final String id;
  final DateTime date;
  final String mood;
  final List<String> symptoms;
  final String? content;
  final int? flowIntensity;
  final double? temperature;

  const Note({
    required this.id,
    required this.date,
    required this.mood,
    this.symptoms = const [],
    this.content,
    this.flowIntensity,
    this.temperature,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        mood,
        symptoms,
        content,
        flowIntensity,
        temperature,
      ];
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? audioUrl;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp, audioUrl];
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime lastPeriodDate;
  final int cycleLength;
  final int periodLength;
  final DateTime? birthDate;
  final String? profilePicture;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.periodLength,
    this.birthDate,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        lastPeriodDate,
        cycleLength,
        periodLength,
        birthDate,
        profilePicture,
      ];
}

// ============================================
// PROVIDERS
// ============================================

// Theme Provider
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // In real app, load from SharedPreferences
    state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    // In real app, save to SharedPreferences
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// User Provider
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodLength,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        lastPeriodDate: lastPeriodDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void logout() {
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
// Part 2: More Providers and State Management

// Period Provider
class PeriodState {
  final List<Period> periods;
  final DateTime? nextPeriodDate;
  final List<DateTime> periodDays;
  final List<DateTime> ovulationDays;
  final List<DateTime> fertilityDays;
  final bool isLoading;
  final String? error;

  PeriodState({
    this.periods = const [],
    this.nextPeriodDate,
    this.periodDays = const [],
    this.ovulationDays = const [],
    this.fertilityDays = const [],
    this.isLoading = false,
    this.error,
  });

  PeriodState copyWith({
    List<Period>? periods,
    DateTime? nextPeriodDate,
    List<DateTime>? periodDays,
    List<DateTime>? ovulationDays,
    List<DateTime>? fertilityDays,
    bool? isLoading,
    String? error,
  }) {
    return PeriodState(
      periods: periods ?? this.periods,
      nextPeriodDate: nextPeriodDate ?? this.nextPeriodDate,
      periodDays: periodDays ?? this.periodDays,
      ovulationDays: ovulationDays ?? this.ovulationDays,
      fertilityDays: fertilityDays ?? this.fertilityDays,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PeriodNotifier extends StateNotifier<PeriodState> {
  PeriodNotifier() : super(PeriodState());

  Future<void> loadPeriods() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate loading from database
      await Future.delayed(const Duration(seconds: 1));
      
      // Create sample period data
      final now = DateTime.now();
      final lastPeriod = Period(
        id: '1',
        startDate: now.subtract(const Duration(days: 15)),
        cycleLength: 28,
        periodLength: 5,
      );
      
      final periods = [lastPeriod];
      final nextPeriod = lastPeriod.nextPeriodDate;
      
      // Calculate special days for current month
      final periodDays = _calculatePeriodDays(periods, now);
      final ovulationDays = _calculateOvulationDays(periods, now);
      final fertilityDays = _calculateFertilityDays(periods, now);
      
      state = state.copyWith(
        periods: periods,
        nextPeriodDate: nextPeriod,
        periodDays: periodDays,
        ovulationDays: ovulationDays,
        fertilityDays: fertilityDays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addPeriod({
    required DateTime startDate,
    DateTime? endDate,
    required int cycleLength,
    required int periodLength,
    List<String> symptoms = const [],
    String? notes,
  }) async {
    try {
      final period = Period(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
        symptoms: symptoms,
        notes: notes,
      );

      final updatedPeriods = [...state.periods, period];
      state = state.copyWith(periods: updatedPeriods);
      await loadPeriods();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePeriod(Period period) async {
    try {
      final updatedPeriods = state.periods.map((p) {
        return p.id == period.id ? period : p;
      }).toList();
      
      state = state.copyWith(periods: updatedPeriods);
      await loadPeriods();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePeriod(String id) async {
    try {
      final updatedPeriods = state.periods.where((p) => p.id != id).toList();
      state = state.copyWith(periods: updatedPeriods);
      await loadPeriods();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<DateTime> _calculatePeriodDays(List<Period> periods, DateTime month) {
    final days = <DateTime>[];
    
    for (final period in periods) {
      final start = period.startDate;
      final end = period.endDate ?? start.add(Duration(days: period.periodLength));
      
      for (var day = start; day.isBefore(end) || day.isAtSameMomentAs(end); 
           day = day.add(const Duration(days: 1))) {
        if (day.month == month.month && day.year == month.year) {
          days.add(day);
        }
      }
    }
    
    return days;
  }

  List<DateTime> _calculateOvulationDays(List<Period> periods, DateTime month) {
    final days = <DateTime>[];
    
    for (final period in periods) {
      final ovulation = period.ovulationDate;
      if (ovulation.month == month.month && ovulation.year == month.year) {
        days.add(ovulation);
      }
    }
    
    return days;
  }

  List<DateTime> _calculateFertilityDays(List<Period> periods, DateTime month) {
    final days = <DateTime>[];
    
    for (final period in periods) {
      final start = period.fertilityWindowStart;
      final end = period.fertilityWindowEnd;
      
      for (var day = start; day.isBefore(end) || day.isAtSameMomentAs(end); 
           day = day.add(const Duration(days: 1))) {
        if (day.month == month.month && day.year == month.year) {
          days.add(day);
        }
      }
    }
    
    return days;
  }
}

final periodProvider = StateNotifierProvider<PeriodNotifier, PeriodState>((ref) {
  return PeriodNotifier();
});

// Note Provider
class NoteState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  NoteState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NoteState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NoteState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NoteNotifier extends StateNotifier<NoteState> {
  NoteNotifier() : super(NoteState());

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate loading from database
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sample notes data
      final notes = <Note>[];
      
      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addNote({
    required String mood,
    List<String> symptoms = const [],
    String? content,
    int? flowIntensity,
    double? temperature,
  }) async {
    try {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        mood: mood,
        symptoms: symptoms,
        content: content,
        flowIntensity: flowIntensity,
        temperature: temperature,
      );

      final updatedNotes = [...state.notes, note];
      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updatedNotes = state.notes.map((n) {
        return n.id == note.id ? note : n;
      }).toList();
      
      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      final updatedNotes = state.notes.where((n) => n.id != id).toList();
      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Map<String, int> getMoodStatistics() {
    final moodCount = <String, int>{};
    
    for (final note in state.notes) {
      moodCount[note.mood] = (moodCount[note.mood] ?? 0) + 1;
    }
    
    return moodCount;
  }

  Map<String, int> getSymptomStatistics() {
    final symptomCount = <String, int>{};
    
    for (final note in state.notes) {
      for (final symptom in note.symptoms) {
        symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
      }
    }
    
    return symptomCount;
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  return NoteNotifier();
});

// Chat Provider
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  void addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'سلام! من دستیار هوشمند سلامتی شما هستم. چطور می‌تونم کمکتون کنم؟',
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, welcomeMessage],
    );
  }

  Future<void> sendMessage(String content) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      error: null,
    );

    try {
      // Simulate AI response
      await Future.delayed(const Duration(seconds: 2));
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'این یک پاسخ نمونه از دستیار هوشمند است. در نسخه واقعی، این پیام از Gemini AI دریافت می‌شود.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: e.toString(),
      );
      
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'متأسفم، در حال حاضر نمی‌تونم پاسخ بدم. لطفاً دوباره تلاش کنید.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
      );
    }
  }

  void clearChat() {
    state = ChatState();
    addWelcomeMessage();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

// ============================================
// WIDGETS
// ============================================

// Gradient Button Widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final double? width;
  final double height;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
    this.width,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? AppColors.buttonGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: (gradientColors ?? AppColors.buttonGradient).first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
// Part 3: Screens - Splash and Onboarding

// ============================================
// SPLASH SCREEN
// ============================================

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : AppColors.splashGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: isDarkMode
                      ? Icon(
                          Icons.wb_sunny_rounded,
                          size: 150,
                          color: AppColors.darkPrimary,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 100,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                Text(
                  'چرخه من',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'دستیار هوشمند سلامتی',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
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

// ============================================
// ONBOARDING SCREEN
// ============================================

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'به‌سادگی چرخه‌ات را دنبال کن',
      description: 'پیش‌بینی دقیق و آسان دوره‌های قاعدگی',
      image: 'assets/images/onboarding1.svg',
      backgroundColor: AppColors.pastelPink,
    ),
    OnboardingData(
      title: 'دستیار هوشمند برای سلامتت',
      description: 'چت با هوش مصنوعی برای پاسخ به سوالاتت',
      image: 'assets/images/onboarding2.svg',
      backgroundColor: AppColors.pastelBlue,
    ),
    OnboardingData(
      title: 'کنترل سلامتی در دستان تو',
      description: 'ثبت علائم و دریافت بینش‌های مفید',
      image: 'assets/images/onboarding3.svg',
      backgroundColor: AppColors.pastelGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.darkBackground, AppColors.darkSurface]
                    : [
                        _pages[_currentPage].backgroundColor.withOpacity(0.3),
                        Colors.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'رد شدن',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Sunflower decoration for dark mode
                              if (isDarkMode)
                                Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.darkPrimary.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 150,
                                    color: AppColors.darkPrimary,
                                  ),
                                )
                              else
                                Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _pages[index].backgroundColor.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    size: 100,
                                    color: _pages[index].backgroundColor,
                                  ),
                                ),
                              const SizedBox(height: 48),
                              Text(
                                _pages[index].title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _pages[index].description,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Indicators and button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // اصلاح شده: استفاده از SmoothPageIndicator به جای AnimatedSmoothIndicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: isDarkMode
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          dotColor: isDarkMode
                              ? Colors.white24
                              : Colors.black12,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                          spacing: 8,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_currentPage == _pages.length - 1)
                        GradientButton(
                          text: 'شروع کن',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegistrationScreen(),
                              ),
                            );
                          },
                          width: double.infinity,
                        )
                      else
                        GradientButton(
                          text: 'بعدی',
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          width: double.infinity,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// REGISTRATION SCREEN
// ============================================

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  DateTime? _selectedDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.lightPrimary,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تمام فیلدها را پر کنید'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userProvider.notifier).register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        lastPeriodDate: _selectedDate!,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ثبت نام: ${e.toString()}'),
          backgroundColor: AppColors.lightError,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      // Header with sunflower for dark mode
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: isDarkMode
                                  ? [
                                      AppColors.darkPrimary.withOpacity(0.3),
                                      Colors.transparent,
                                    ]
                                  : [
                                      AppColors.lightPrimary.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                            ),
                          ),
                          child: Icon(
                            isDarkMode ? Icons.wb_sunny_rounded : Icons.favorite_rounded,
                            size: 60,
                            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ایجاد حساب کاربری',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اطلاعات خود را برای شروع وارد کنید',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'نام',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً نام خود را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'ایمیل',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً ایمیل خود را وارد کنید';
                          }
                          if (!value.contains('@')) {
                            return 'ایمیل معتبر نیست';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'رمز عبور',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً رمز عبور را وارد کنید';
                          }
                          if (value.length < 6) {
                            return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Period date selector
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode 
                                  ? AppColors.darkPrimary.withOpacity(0.3)
                                  : AppColors.lightPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? 'تاریخ شروع آخرین پریود'
                                      : DateFormat('yyyy/MM/dd').format(_selectedDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate == null
                                        ? Colors.grey
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Cycle length selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طول دوره (روز)',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_cycleLength > 21) {
                                      setState(() {
                                        _cycleLength--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                                Text(
                                  '$_cycleLength',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_cycleLength < 35) {
                                      setState(() {
                                        _cycleLength++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Period length selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طول پریود (روز)',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_periodLength > 3) {
                                      setState(() {
                                        _periodLength--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                                Text(
                                  '$_periodLength',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_periodLength < 7) {
                                      setState(() {
                                        _periodLength++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Register button
                      GradientButton(
                        text: 'ثبت نام',
                        onPressed: _register,
                        isLoading: _isLoading,
                        width: double.infinity,
                        gradientColors: isDarkMode
                            ? [AppColors.darkPrimary, AppColors.darkSecondary]
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Part 4: Dashboard Screen and Components

// ============================================
// DASHBOARD SCREEN
// ============================================

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Load user periods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(periodProvider.notifier).loadPeriods();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final periodState = ref.watch(periodProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'چرخه من',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(periodProvider.notifier).loadPeriods();
        },
        color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calendar Card
            CalendarCard(
              isDarkMode: isDarkMode,
              periodDays: periodState.periodDays,
              ovulationDays: periodState.ovulationDays,
              fertilityDays: periodState.fertilityDays,
            ),
            const SizedBox(height: 16),
            
            // Next Period Prediction
            if (periodState.nextPeriodDate != null)
              _buildNextPeriodCard(context, periodState.nextPeriodDate!, isDarkMode),
            const SizedBox(height: 16),
            
            // Today's Status
            StatusCard(isDarkMode: isDarkMode),
            const SizedBox(height: 16),
            
            // Insights
            InsightCard(isDarkMode: isDarkMode),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) {
          _fabAnimationController.forward();
        },
        onTapUp: (_) {
          _fabAnimationController.reverse();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatScreen(),
            ),
          );
        },
        onTapCancel: () {
          _fabAnimationController.reverse();
        },
        child: ScaleTransition(
          scale: _fabScaleAnimation,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.darkPrimary, AppColors.darkSecondary]
                    : AppColors.buttonGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: isDarkMode ? AppColors.darkBackground : Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNextPeriodCard(BuildContext context, DateTime nextPeriod, bool isDarkMode) {
    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  AppColors.darkPrimary.withOpacity(0.2),
                  AppColors.darkSecondary.withOpacity(0.2),
                ]
              : [
                  AppColors.pastelPink.withOpacity(0.3),
                  AppColors.pastelPurple.withOpacity(0.3),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkPrimary.withOpacity(0.3)
              : AppColors.lightPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$daysUntil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkBackground : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'پریود بعدی',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'روز مانده تا شروع',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ============================================
// CALENDAR CARD WIDGET
// ============================================

class CalendarCard extends StatefulWidget {
  final bool isDarkMode;
  final List<DateTime> periodDays;
  final List<DateTime> ovulationDays;
  final List<DateTime> fertilityDays;

  const CalendarCard({
    super.key,
    required this.isDarkMode,
    required this.periodDays,
    required this.ovulationDays,
    required this.fertilityDays,
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                ),
                selectedDecoration: BoxDecoration(
                  color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: (widget.isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary)
                      .withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  Color? markerColor;
                  
                  if (widget.periodDays.any((d) => isSameDay(d, day))) {
                    markerColor = AppColors.periodColor;
                  } else if (widget.ovulationDays.any((d) => isSameDay(d, day))) {
                    markerColor = AppColors.ovulationColor;
                  } else if (widget.fertilityDays.any((d) => isSameDay(d, day))) {
                    markerColor = AppColors.fertilityColor;
                  }
                  
                  if (markerColor != null) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: markerColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: markerColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('پریود', AppColors.periodColor),
                _buildLegendItem('تخمک‌گذاری', AppColors.ovulationColor),
                _buildLegendItem('باروری', AppColors.fertilityColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

// ============================================
// STATUS CARD WIDGET
// ============================================

class StatusCard extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const StatusCard({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends ConsumerState<StatusCard> {
  String _selectedMood = '';
  final List<String> _selectedSymptoms = [];
  final _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'خوب'},
    {'emoji': '😐', 'label': 'معمولی'},
    {'emoji': '😔', 'label': 'غمگین'},
    {'emoji': '😤', 'label': 'عصبانی'},
    {'emoji': '😴', 'label': 'خسته'},
  ];

  final List<String> _symptoms = [
    'دل‌درد',
    'سردرد',
    'کمردرد',
    'حساسیت سینه',
    'تهوع',
    'خستگی',
    'نفخ',
    'تغییرات خلقی',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveStatus() {
    if (_selectedMood.isEmpty && _selectedSymptoms.isEmpty && _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً حداقل یک مورد را انتخاب کنید'),
        ),
      );
      return;
    }

    ref.read(noteProvider.notifier).addNote(
      mood: _selectedMood,
      symptoms: _selectedSymptoms,
      content: _noteController.text,
    );

    // Reset form
    setState(() {
      _selectedMood = '';
      _selectedSymptoms.clear();
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('وضعیت امروز ثبت شد'),
        backgroundColor: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'وضعیت امروز',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Mood selector
            Text(
              'احساست چطوره؟',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = isSelected ? '' : mood['label'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
                              .withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? (widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Symptoms selector
            Text(
              'علائم',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  backgroundColor: widget.isDarkMode ? AppColors.darkSurface : Colors.grey[100],
                  selectedColor: (widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary)
                      .withOpacity(0.2),
                  checkmarkColor: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Note input
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'یادداشت...',
                filled: true,
                fillColor: widget.isDarkMode ? AppColors.darkSurface : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                  foregroundColor: widget.isDarkMode ? AppColors.darkBackground : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'ذخیره وضعیت',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// INSIGHT CARD WIDGET
// ============================================

class InsightCard extends ConsumerWidget {
  final bool isDarkMode;

  const InsightCard({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodState = ref.watch(periodProvider);
    
    final insights = _generateInsights(periodState);
    
    return Card(
      elevation: isDarkMode ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    AppColors.darkSurface,
                    AppColors.darkSurface.withOpacity(0.9),
                  ]
                : [
                    Colors.white,
                    AppColors.pastelYellow.withOpacity(0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDarkMode 
                        ? AppColors.darkPrimary 
                        : AppColors.lightPrimary)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'بینش‌های امروز',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...insights.map((insight) => _buildInsightItem(
              context,
              insight['icon'] as IconData,
              insight['title'] as String,
              insight['description'] as String,
              insight['color'] as Color,
            )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights(PeriodState state) {
    final insights = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Check if in period
    if (state.periodDays.any((day) => 
        day.day == now.day && day.month == now.month && day.year == now.year)) {
      insights.add({
        'icon': Icons.water_drop,
        'title': 'روز پریود',
        'description': 'آب زیاد بنوش و استراحت کن',
        'color': AppColors.periodColor,
      });
    }
    
    // Check if in fertility window
    if (state.fertilityDays.any((day) => 
        day.day == now.day && day.month == now.month && day.year == now.year)) {
      insights.add({
        'icon': Icons.favorite,
        'title': 'پنجره باروری',
        'description': 'احتمال بارداری در بالاترین حد است',
        'color': AppColors.fertilityColor,
      });
    }
    
    // Check if ovulation day
    if (state.ovulationDays.any((day) => 
        day.day == now.day && day.month == now.month && day.year == now.year)) {
      insights.add({
        'icon': Icons.stars,
        'title': 'روز تخمک‌گذاری',
        'description': 'بدنت در اوج انرژی است',
        'color': AppColors.ovulationColor,
      });
    }
    
    // If no specific day, show general tip
    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.self_improvement,
        'title': 'روز عادی',
        'description': 'به بدنت گوش بده و از خودت مراقبت کن',
        'color': isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary,
      });
    }
    
    return insights;
  }

  Widget _buildInsightItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Part 5: Chat Screen and Components

// ============================================
// CHAT SCREEN
// ============================================

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _speechToText = stt.SpeechToText();
  final _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  late AnimationController _animationController;
  late Animation<double> _micAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _micAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Send welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).addWelcomeMessage();
    });
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('fa-IR');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برای استفاده از میکروفون باید دسترسی بدهید'),
        ),
      );
      return;
    }

    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
        localeId: 'fa_IR',
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  Future<void> _speak(String text) async {
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(chatProvider);
    
    // Auto scroll when new message arrives
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('دستیار هوشمند'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () {
                _flutterTts.stop();
                setState(() => _isSpeaking = false);
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length && chatState.isTyping) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: TypingIndicator(),
                    );
                  }
                  
                  final message = chatState.messages[index];
                  return MessageBubble(
                    message: message,
                    isDarkMode: isDarkMode,
                    onSpeak: () => _speak(message.content),
                  );
                },
              ),
            ),
            
            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Text input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? AppColors.darkBackground 
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'سوالت رو بپرس...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            // Send button
                            IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: chatState.isLoading
                                    ? Colors.grey
                                    : (isDarkMode 
                                        ? AppColors.darkPrimary 
                                        : AppColors.lightPrimary),
                              ),
                              onPressed: chatState.isLoading ? null : _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Microphone button
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isListening ? _micAnimation.value : 1.0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isListening
                                      ? [Colors.red, Colors.redAccent]
                                      : (isDarkMode
                                          ? [AppColors.darkPrimary, AppColors.darkSecondary]
                                          : AppColors.buttonGradient),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: isDarkMode ? AppColors.darkBackground : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // پایان کلاس _ChatScreenState

// ============================================
// MESSAGE BUBBLE - کلاس جداگانه
// ============================================

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isDarkMode;
  final VoidCallback onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isDarkMode,
    required this.onSpeak,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: widget.message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: widget.message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: widget.message.isUser
                        ? LinearGradient(
                            colors: widget.isDarkMode
                                ? [AppColors.darkPrimary, AppColors.darkSecondary]
                                : AppColors.buttonGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: widget.message.isUser
                        ? null
                        : (widget.isDarkMode
                            ? AppColors.darkSurface
                            : Colors.grey[100]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(widget.message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(widget.message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message.content,
                    style: TextStyle(
                      color: widget.message.isUser
                          ? (widget.isDarkMode
                              ? AppColors.darkBackground
                              : Colors.white)
                          : (widget.isDarkMode
                              ? Colors.white
                              : Colors.black87),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.message.isUser)
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_outlined,
                          size: 18,
                          color: widget.isDarkMode
                              ? Colors.white54
                              : Colors.black38,
                        ),
                        onPressed: widget.onSpeak,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    Text(
                      _formatTime(widget.message.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode
                            ? Colors.white54
                            : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} // پایان کلاس _MessageBubbleState

// ============================================
// TYPING INDICATOR - کلاس جداگانه
// ============================================

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, -5 * _animations[index].value),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
} // پایان کلاس _TypingIndicatorState

// ============================================
// GEMINI DATASOURCE
// ============================================

class GeminiDatasource {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with your API key
  late final GenerativeModel _model;

  GeminiDatasource() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final prompt = '''
      شما یک دستیار هوشمند سلامتی زنان هستید که در زمینه سلامت قاعدگی و باروری تخصص دارید.
      با لحنی دوستانه، همدلانه و حرفه‌ای به سوالات پاسخ دهید.
      اطلاعات دقیق و علمی ارائه دهید اما از زبان ساده استفاده کنید.
      در صورت نیاز به مشاوره پزشکی، حتماً توصیه به مراجعه به پزشک کنید.
      
      سوال کاربر: $message
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'متأسفم، نتونستم پاسخ مناسبی پیدا کنم.';
    } catch (e) {
      throw Exception('خطا در ارتباط با هوش مصنوعی: $e');
    }
  }
}
// Part 6: Notes Screen and Chart Components

// ============================================
// NOTES SCREEN
// ============================================

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load notes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(noteProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final noteState = ref.watch(noteProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('یادداشت‌های من'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
          labelColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'یادداشت‌ها', icon: Icon(Icons.note)),
            Tab(text: 'نمودار احساسات', icon: Icon(Icons.mood)),
            Tab(text: 'نمودار علائم', icon: Icon(Icons.healing)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Notes list
          _buildNotesList(noteState, isDarkMode),
          
          // Mood chart
          _buildMoodChart(noteState, isDarkMode),
          
          // Symptom chart
          _buildSymptomChart(noteState, isDarkMode),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddNoteDialog(context, isDarkMode);
              },
              backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
              child: Icon(
                Icons.add,
                color: isDarkMode ? AppColors.darkBackground : Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildNotesList(NoteState noteState, bool isDarkMode) {
    if (noteState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (noteState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'هنوز یادداشتی ثبت نکردی',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای شروع روی دکمه + بزن',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: noteState.notes.length,
      itemBuilder: (context, index) {
        final note = noteState.notes[index];
        return NoteCard(
          note: note,
          isDarkMode: isDarkMode,
          onDelete: () {
            ref.read(noteProvider.notifier).deleteNote(note.id);
          },
        );
      },
    );
  }

  Widget _buildMoodChart(NoteState noteState, bool isDarkMode) {
    if (noteState.notes.isEmpty) {
      return const Center(
        child: Text('داده‌ای برای نمایش وجود ندارد'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MoodChart(
        notes: noteState.notes,
        isDarkMode: isDarkMode,
      ),
    );
  }

  Widget _buildSymptomChart(NoteState noteState, bool isDarkMode) {
    if (noteState.notes.isEmpty) {
      return const Center(
        child: Text('داده‌ای برای نمایش وجود ندارد'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SymptomChart(
        notes: noteState.notes,
        isDarkMode: isDarkMode,
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddNoteSheet(isDarkMode: isDarkMode),
    );
  }
}

// ============================================
// NOTE CARD WIDGET
// ============================================

class NoteCard extends StatefulWidget {
  final Note note;
  final bool isDarkMode;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.isDarkMode,
    required this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'خوب':
        return '😊';
      case 'معمولی':
        return '😐';
      case 'غمگین':
        return '😔';
      case 'عصبانی':
        return '😤';
      case 'خسته':
        return '😴';
      default:
        return '😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: widget.isDarkMode ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.isDarkMode
                      ? [
                          AppColors.darkSurface,
                          AppColors.darkSurface.withOpacity(0.9),
                        ]
                      : [
                          Colors.white,
                          AppColors.lightBackground,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (widget.isDarkMode 
                              ? AppColors.darkPrimary 
                              : AppColors.lightPrimary)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getMoodEmoji(widget.note.mood),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE، d MMMM', 'fa_IR')
                                  .format(widget.note.date),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(widget.note.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: widget.isDarkMode 
                              ? Colors.red[300] 
                              : Colors.red[400],
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('حذف یادداشت'),
                              content: const Text('آیا از حذف این یادداشت مطمئن هستید؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('انصراف'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onDelete();
                                  },
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(color: Colors.red[400]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Symptoms
                  if (widget.note.symptoms.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.note.symptoms.map((symptom) {
                        return Chip(
                          label: Text(
                            symptom,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode 
                                  ? AppColors.darkBackground 
                                  : Colors.white,
                            ),
                          ),
                          backgroundColor: widget.isDarkMode 
                              ? AppColors.darkPrimary 
                              : AppColors.lightPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Flow intensity
                  if (widget.note.flowIntensity != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 16,
                          color: widget.isDarkMode 
                              ? AppColors.darkPrimary 
                              : AppColors.lightPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'شدت خونریزی: ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.circle,
                            size: 8,
                            color: index < widget.note.flowIntensity!
                                ? (widget.isDarkMode 
                                    ? AppColors.darkPrimary 
                                    : AppColors.lightPrimary)
                                : Colors.grey[300],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Temperature
                  if (widget.note.temperature != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.thermostat,
                          size: 16,
                          color: widget.isDarkMode 
                              ? AppColors.darkPrimary 
                              : AppColors.lightPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'دمای بدن: ${widget.note.temperature}°C',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Content
                  if (widget.note.content != null && widget.note.content!.isNotEmpty) ...[
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.note.content!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      secondChild: Text(
                        widget.note.content!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    if (widget.note.content!.length > 100)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? 'نمایش کمتر' : 'نمایش بیشتر',
                          style: TextStyle(
                            color: widget.isDarkMode 
                                ? AppColors.darkPrimary 
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// ADD NOTE SHEET
// ============================================

class AddNoteSheet extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const AddNoteSheet({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  String _selectedMood = '';
  final List<String> _selectedSymptoms = [];
  final _noteController = TextEditingController();
  final _temperatureController = TextEditingController();
  int? _flowIntensity;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'خوب'},
    {'emoji': '😐', 'label': 'معمولی'},
    {'emoji': '😔', 'label': 'غمگین'},
    {'emoji': '😤', 'label': 'عصبانی'},
    {'emoji': '😴', 'label': 'خسته'},
  ];

  final List<String> _symptoms = [
    'دل‌درد',
    'سردرد',
    'کمردرد',
    'حساسیت سینه',
    'تهوع',
    'خستگی',
    'نفخ',
    'تغییرات خلقی',
    'گرگرفتگی',
    'سرگیجه',
    'یبوست',
    'اسهال',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً احساست رو انتخاب کن'),
        ),
      );
      return;
    }

    ref.read(noteProvider.notifier).addNote(
      mood: _selectedMood,
      symptoms: _selectedSymptoms,
      content: _noteController.text.isEmpty ? null : _noteController.text,
      flowIntensity: _flowIntensity,
      temperature: _temperatureController.text.isEmpty 
          ? null 
          : double.tryParse(_temperatureController.text),
    );

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('یادداشت ذخیره شد'),
        backgroundColor: widget.isDarkMode 
            ? AppColors.darkPrimary 
            : AppColors.lightPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'یادداشت جدید',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Mood selector
              Text(
                'احساست چطوره؟',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = mood['label'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (widget.isDarkMode 
                                ? AppColors.darkPrimary 
                                : AppColors.lightPrimary)
                                .withOpacity(0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (widget.isDarkMode 
                                  ? AppColors.darkPrimary 
                                  : AppColors.lightPrimary)
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode 
                                  ? Colors.white70 
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Symptoms
              Text(
                'علائم',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    backgroundColor: widget.isDarkMode 
                        ? AppColors.darkBackground 
                        : Colors.grey[100],
                    selectedColor: (widget.isDarkMode 
                        ? AppColors.darkPrimary 
                        : AppColors.lightPrimary)
                        .withOpacity(0.2),
                    checkmarkColor: widget.isDarkMode 
                        ? AppColors.darkPrimary 
                        : AppColors.lightPrimary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Flow intensity
              Text(
                'شدت خونریزی',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  final intensity = index + 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _flowIntensity = intensity;
                        });
                      },
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _flowIntensity == intensity
                              ? (widget.isDarkMode 
                                  ? AppColors.darkPrimary 
                                  : AppColors.lightPrimary)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.water_drop,
                            size: 20,
                            color: _flowIntensity == intensity
                                ? Colors.white
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Temperature
              Text(
                'دمای بدن (اختیاری)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '36.5',
                  suffixText: '°C',
                  filled: true,
                  fillColor: widget.isDarkMode 
                      ? AppColors.darkBackground 
                      : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              
              // Note
              Text(
                'یادداشت',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'هر چیزی که می‌خوای یادداشت کن...',
                  filled: true,
                  fillColor: widget.isDarkMode 
                      ? AppColors.darkBackground 
                      : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode 
                        ? AppColors.darkPrimary 
                        : AppColors.lightPrimary,
                    foregroundColor: widget.isDarkMode 
                        ? AppColors.darkBackground 
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'ذخیره یادداشت',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// MOOD CHART WIDGET
// ============================================

class MoodChart extends StatelessWidget {
  final List<Note> notes;
  final bool isDarkMode;

  const MoodChart({
    super.key,
    required this.notes,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final moodData = _calculateMoodData();
    
    return Column(
      children: [
        Text(
          'روند احساسات در ۳۰ روز گذشته',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDarkMode 
                        ? Colors.white10 
                        : Colors.black12,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      String emoji;
                      switch (value.toInt()) {
                        case 5:
                          emoji = '😊';
                          break;
                        case 4:
                          emoji = '🙂';
                          break;
                        case 3:
                          emoji = '😐';
                          break;
                        case 2:
                          emoji = '😔';
                          break;
                        case 1:
                          emoji = '😢';
                          break;
                        default:
                          return const SizedBox();
                      }
                      return Text(emoji, style: const TextStyle(fontSize: 16));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: 30,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: moodData,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [AppColors.darkPrimary, AppColors.darkSecondary]
                        : AppColors.buttonGradient,
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: isDarkMode 
                            ? AppColors.darkPrimary 
                            : AppColors.lightPrimary,
                        strokeWidth: 2,
                        strokeColor: isDarkMode 
                            ? AppColors.darkBackground 
                            : Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: (isDarkMode
                          ? [AppColors.darkPrimary, AppColors.darkSecondary]
                          : AppColors.buttonGradient)
                          .map((color) => color.withOpacity(0.3))
                          .toList(),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _calculateMoodData() {
    final Map<int, double> dailyMood = {};
    final now = DateTime.now();
    
    for (final note in notes) {
      final dayDiff = now.difference(note.date).inDays;
      if (dayDiff <= 30) {
        final moodValue = _getMoodValue(note.mood);
        dailyMood[30 - dayDiff] = moodValue;
      }
    }
    
    final spots = <FlSpot>[];
    for (int i = 0; i <= 30; i++) {
      spots.add(FlSpot(i.toDouble(), dailyMood[i] ?? 3));
    }
    
    return spots;
  }

  double _getMoodValue(String mood) {
    switch (mood) {
      case 'خوب':
        return 5;
      case 'معمولی':
        return 3;
      case 'غمگین':
        return 2;
      case 'عصبانی':
        return 2;
      case 'خسته':
        return 2;
      default:
        return 3;
    }
  }
}

// ============================================
// SYMPTOM CHART WIDGET
// ============================================

class SymptomChart extends StatelessWidget {
  final List<Note> notes;
  final bool isDarkMode;

  const SymptomChart({
    super.key,
    required this.notes,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final symptomData = _calculateSymptomData();
    
    if (symptomData.isEmpty) {
      return Center(
        child: Text(
          'هنوز علائمی ثبت نشده',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    
    return Column(
      children: [
        Text(
          'شایع‌ترین علائم',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: symptomData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: isDarkMode 
                      ? AppColors.darkSurface 
                      : Colors.grey[800],
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${symptomData.keys.elementAt(groupIndex)}\n${rod.toY.toInt()} بار',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < symptomData.length) {
                        final symptom = symptomData.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              symptom,
                              style: TextStyle(
                                color: isDarkMode 
                                    ? Colors.white54 
                                    : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 60,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: isDarkMode 
                              ? Colors.white54 
                              : Colors.black54,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
              barGroups: symptomData.entries.map((entry) {
                final index = symptomData.keys.toList().indexOf(entry.key);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [AppColors.darkPrimary, AppColors.darkSecondary]
                            : AppColors.buttonGradient,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateSymptomData() {
    final symptomCount = <String, int>{};
    
    for (final note in notes) {
      for (final symptom in note.symptoms) {
        symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
      }
    }
    
    // Sort by count and take top 6
    final sortedEntries = symptomCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topSymptoms = <String, int>{};
    for (var i = 0; i < sortedEntries.length && i < 6; i++) {
      topSymptoms[sortedEntries[i].key] = sortedEntries[i].value;
    }
    
    return topSymptoms;
  }
}
// Part 7: Final Components and Setup Instructions

// ============================================
// ANIMATED SMOOTH INDICATOR WIDGET
// ============================================
// ============================================
// EXPANDING DOTS EFFECT
// ==========================================

// ============================================
// USECASES
// ============================================

class PredictNextPeriodUseCase {
  DateTime call(Period lastPeriod) {
    return lastPeriod.startDate.add(Duration(days: lastPeriod.cycleLength));
  }
}

// ============================================
// REPOSITORY INTERFACES
// ============================================

abstract class PeriodRepository {
  Future<List<Period>> getAllPeriods();
  Future<Period?> getPeriodById(String id);
  Future<void> addPeriod(Period period);
  Future<void> updatePeriod(Period period);
  Future<void> deletePeriod(String id);
  Future<Period?> getLastPeriod();
  Future<List<Period>> getPeriodsByDateRange(DateTime start, DateTime end);
}

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> getNotesByDate(DateTime date);
  Future<List<Note>> getNotesByDateRange(DateTime start, DateTime end);
  Future<List<Note>> getNotesByMood(String mood);
}

abstract class UserRepository {
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodLength,
  });
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<void> updateUser(User user);
}

// ============================================
// END OF COMPLETE CODE
// ============================================




