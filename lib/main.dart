import 'package:flutter/material.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/res/fonts.dart';
import 'core/services/router.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  //Supabase setup
await Supabase.initialize(
  anonKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2cXN6cXFya25sa3ViamlscHNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMTEzMjAsImV4cCI6MjA1OTU4NzMyMH0.QPKtvmju4W_XGCvCIxePrCNU5dMJri6NJWzyiSLTz78" ,
  url:"https://dvqszqqrknlkubjilpsj.supabase.co" ,
);

  runApp(MyApp());
}  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenloop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: Fonts.fontFamily,
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(0, 42, 42, 43),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
          secondary: Colors.greenAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        cardColor: Color(0xFFFFFFFF),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF212121)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: Fonts.fontFamily,
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Color(0xFF1E9C24),
          secondary: Color(0xFF81C784),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Color(0xFF181C1B),
        cardColor: Color(0xFF232A28),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF8F9FA)),
          bodyMedium: TextStyle(color: Color(0xFFF8F9FA)),
        ),
      ),
      onGenerateRoute: generateRoute,
    );
  }
}
