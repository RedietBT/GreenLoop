import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/application/auth/auth_get.dart';


void main() async{
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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // Set the initial route to the SignUpScreen
      routes: {
        '/': (context) => const AuthGet(),
        // '/auth/callback': (context) => const AuthCallbackScreen(),
        // '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
