import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';

class RegisterForRecyclingBody extends StatefulWidget {
  final String role;
  const RegisterForRecyclingBody({super.key, required this.role});

  @override
  State<RegisterForRecyclingBody> createState() =>
      _RegisterForRecyclingBodyState();
}

class _RegisterForRecyclingBodyState extends State<RegisterForRecyclingBody>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _centerNameController = TextEditingController();
  final _contactController = TextEditingController();

  String password = '';
  String confirmPassword = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _centerNameController.dispose();
    _contactController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Roboto';

    // Custom colors from your palette
    const labelColor = AppColors.mischka;
    const inputTextColor = AppColors.mirage;
    const buttonTextColor = Colors.white; // Make button text white for contrast
    const buttonColor = AppColors.turquoise; // Use turquoise for button

    return BlocConsumer<RegisterForRecyclingCubit, RegisterForRecyclingState>(
      listener: (context, state) {
        if (state is RegisterForRecyclingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RegisterForRecyclingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful!")),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Gradient Header Text
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  );
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.blueChill, AppColors.turquoise],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Register at Recycling Center',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Overridden by shader
                      shadows: [
                        Shadow(
                          color: AppColors.blueChill.withOpacity(0.7),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Fade in the form itself
              FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: RecyclingRegistrationForm(
                    emailController: _emailController,
                    centerNameController: _centerNameController,
                    contactController: _contactController,
                    password: password,
                    confirmPassword: confirmPassword,
                    onPasswordChanged: (val) => setState(() => password = val),
                    onConfirmPasswordChanged: (val) =>
                        setState(() => confirmPassword = val),
                    isLoading: state is RegisterForRecyclingLoading,
                    onSubmit: () {
                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Passwords do not match.")),
                        );
                        return;
                      }
                      context.read<RegisterForRecyclingCubit>().registerRecycling(
                            centerName: _centerNameController.text.trim(),
                            contactInfo: _contactController.text.trim(),
                            email: _emailController.text.trim(),
                            password: password,
                            userType: widget.role,
                          );
                    },
                    fontFamily: fontFamily,
                    labelColor: labelColor,
                    inputTextColor: inputTextColor,
                    buttonTextColor: buttonTextColor,
                    buttonColor: buttonColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecyclingRegistrationForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController centerNameController;
  final TextEditingController contactController;
  final String password;
  final String confirmPassword;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String fontFamily;
  final Color labelColor;
  final Color inputTextColor;
  final Color buttonTextColor;
  final Color buttonColor;

  const RecyclingRegistrationForm({
    Key? key,
    required this.emailController,
    required this.centerNameController,
    required this.contactController,
    required this.password,
    required this.confirmPassword,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.fontFamily,
    required this.labelColor,
    required this.inputTextColor,
    required this.buttonTextColor,
    required this.buttonColor,
  }) : super(key: key);

  @override
  State<RecyclingRegistrationForm> createState() =>
      _RecyclingRegistrationFormState();
}

class _RecyclingRegistrationFormState extends State<RecyclingRegistrationForm> {
  // Track hover for each input field and the button
  bool _hoverCenterName = false;
  bool _hoverContact = false;
  bool _hoverEmail = false;
  bool _hoverPassword = false;
  bool _hoverConfirmPassword = false;
  bool _hoverButton = false;

  InputDecoration inputDecoration(String label, bool isHovered) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: widget.labelColor,
        fontFamily: widget.fontFamily,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.labelColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.persianGreen),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Add box shadow and border color on hover
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isHovered ? AppColors.turquoise : widget.labelColor.withOpacity(0.3),
          width: isHovered ? 2 : 1,
        ),
      ),
    );
  }

  TextStyle get inputTextStyle => TextStyle(
        color: widget.inputTextColor,
        fontFamily: widget.fontFamily,
        fontSize: 16,
      );

  TextStyle get buttonTextStyle => TextStyle(
        fontFamily: widget.fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: widget.buttonTextColor,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      );

  BoxDecoration buttonDecoration(bool hovered) {
    return BoxDecoration(
      color: widget.buttonColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: hovered
          ? [
              BoxShadow(
                color: AppColors.deepSeaGreen.withOpacity(0.6),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
            ]
          : [
              BoxShadow(
                color: AppColors.deepSeaGreen.withOpacity(0.35),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hoverCenterName = true),
          onExit: (_) => setState(() => _hoverCenterName = false),
          child: TextField(
            controller: widget.centerNameController,
            decoration: inputDecoration('Center Name', _hoverCenterName),
            style: inputTextStyle,
          ),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _hoverContact = true),
          onExit: (_) => setState(() => _hoverContact = false),
          child: TextField(
            controller: widget.contactController,
            decoration: inputDecoration('Contact Info', _hoverContact),
            style: inputTextStyle,
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _hoverEmail = true),
          onExit: (_) => setState(() => _hoverEmail = false),
          child: TextField(
            controller: widget.emailController,
            decoration: inputDecoration('Email', _hoverEmail),
            style: inputTextStyle,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _hoverPassword = true),
          onExit: (_) => setState(() => _hoverPassword = false),
          child: TextField(
            decoration: inputDecoration('Password', _hoverPassword),
            obscureText: true,
            onChanged: widget.onPasswordChanged,
            style: inputTextStyle,
          ),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _hoverConfirmPassword = true),
          onExit: (_) => setState(() => _hoverConfirmPassword = false),
          child: TextField(
            decoration: inputDecoration('Confirm Password', _hoverConfirmPassword),
            obscureText: true,
            onChanged: widget.onConfirmPasswordChanged,
            style: inputTextStyle,
          ),
        ),
        const SizedBox(height: 24),
        MouseRegion(
          onEnter: (_) => setState(() => _hoverButton = true),
          onExit: (_) => setState(() => _hoverButton = false),
          child: GestureDetector(
            onTap: widget.isLoading ? null : widget.onSubmit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: buttonDecoration(_hoverButton && !widget.isLoading),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Register", style: buttonTextStyle),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: Text(
              "have an account? Login here.",
              style: TextStyle(
                fontFamily: Fonts.fontFamily,
                color: AppColors.mirage,
                decoration: TextDecoration.underline,
                ),
                ),
                ),
      ],
    );
  }
}
