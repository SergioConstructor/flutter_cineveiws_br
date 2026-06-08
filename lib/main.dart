import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'providers/movie_provider.dart';
import 'providers/social_provider.dart';
import 'providers/list_provider.dart';
import 'providers/diary_provider.dart';
import 'screens/tela_login.dart';
import 'screens/discover_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/review_detail_screen.dart';
import 'screens/public_profile_screen.dart';
import 'screens/followers_screen.dart';
import 'screens/list_detail_screen.dart';
import 'screens/list_edit_screen.dart';
import 'screens/diary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  await storageService.init();

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MovieProvider(storageService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialProvider(storageService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListProvider(storageService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => DiaryProvider(storageService)..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'CineViews BR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            primary: Colors.orange,
            secondary: Colors.amber,
            surface: const Color(0xFF1E1E1E),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const LoginScreen(),
        routes: {
          '/discover': (context) => const DiscoverScreen(),
          '/feed': (context) => const FeedScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/search': (context) => const SearchResultsScreen(),
          '/review-detail': (context) => const ReviewDetailScreen(),
          '/public-profile': (context) => const PublicProfileScreen(),
          '/followers': (context) => const FollowersScreen(),
          '/list-detail': (context) => const ListDetailScreen(),
          '/list-edit': (context) => const ListEditScreen(),
          '/diary': (context) => const DiaryScreen(),
        },
      ),
    );
  }
}
