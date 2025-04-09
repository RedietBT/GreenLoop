import 'package:flutter/material.dart';
import 'package:greenloop/application/auth/login_page.dart';
import 'package:greenloop/application/auth/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGet extends StatelessWidget {
  const AuthGet({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:Supabase.instance.client.auth.onAuthStateChange, 

      //Build approprate page
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return ProfilePage();
        } else {
          return LoginPage();
        }
        
  },);
}
}