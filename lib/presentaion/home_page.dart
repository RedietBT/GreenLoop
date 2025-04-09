import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenloop/presentaion/login_page.dart';
import 'package:greenloop/presentaion/register_as_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 126, 85),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                          "Welcome to",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "GreenLoop",
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5, // Decreased width
                    child: ElevatedButton(
                    onPressed: () => _navigateTo(const LoginPage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color.fromARGB(255, 3, 126, 85),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      ),
                       textStyle: const TextStyle(
                      fontSize: 18, // Increased font size
                      fontWeight: FontWeight.bold, // Made text bold
                      ),
                    ),
                    child: const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5, // Decreased width
                    child: ElevatedButton(
                    onPressed: () => _navigateTo(const RegisterAsPage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color.fromARGB(255, 3, 126, 85),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      ),
                       textStyle: const TextStyle(
                      fontSize: 18, // Increased font size
                      fontWeight: FontWeight.bold, // Made text bold
                      ),
                    ),
                    child: const Text("Sign Up"),
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
}
