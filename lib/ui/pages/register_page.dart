import 'package:flutter/material.dart';
import 'package:gh6_ucap/themes/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  final bool _agreedToPolicy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul Halaman
              Text(
                'Buat Akunmu!',
                style: AppTheme.h2.copyWith(color: AppTheme.primaryColorDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Form Input
              _buildTextField(
                hintText: 'Nama Lengkap',
                icon: Icons.person_outline_rounded,
                suffixIcon: Icons.check_circle_rounded,
                isSuffixVisible: true, // Contoh: Anggap nama valid
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                suffixIcon: Icons.check_circle_rounded,
                isSuffixVisible: true, // Contoh: Anggap email valid
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 36),

              // Tombol Sign-Up
              _buildSignUpButton(),
              const SizedBox(height: 24),

              // Tombol Google
              _buildGoogleButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk membuat text field yang konsisten
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    bool isSuffixVisible = false,
  }) {
    return TextField(
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppTheme.textSecondaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : (isSuffixVisible
                  ? Icon(suffixIcon, color: AppTheme.successColor)
                  : null),
        // Menggunakan InputDecorationTheme dari AppTheme secara implisit
      ),
    );
  }

  /// Widget untuk tombol Sign-Up utama
  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
        ),
        onPressed: () {
          // Logika untuk sign up
        },
        // Menggunakan ElevatedButtonTheme dari AppTheme secara implisit
        child: Text('SIGN-UP', style: AppTheme.button),
      ),
    );
  }

  /// Widget untuk tombol Continue with Google
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Logika untuk login/register dengan Google
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Image.asset('assets/google_logo.png', height: 24),
        ),
        label: Text('CONTINUE WITH GOOGLE', style: AppTheme.subtitle1),
      ),
    );
  }
}
