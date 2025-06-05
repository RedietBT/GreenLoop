import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/core/services/router.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2cXN6cXFya25sa3ViamlscHNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwMTEzMjAsImV4cCI6MjA1OTU4NzMyMH0.QPKtvmju4W_XGCvCIxePrCNU5dMJri6NJWzyiSLTz78",
    url: "https://dvqszqqrknlkubjilpsj.supabase.co",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterAsCubit()),
        // Add more Cubits/Blocs here if needed
      ],
      child: MaterialApp(
        title: 'Greenloop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: Fonts.fontFamily,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green,
            secondary: Colors.greenAccent,
          ),
        ),
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
