import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/bloc/auth/auth_bloc.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );
    }
  }

  void _showCustomAlert({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.body2.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? AppTheme.successColor
            : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showCustomAlert(message: state.message, isSuccess: true);
            routes.goNamed(RouteName.main);
          } else if (state is AuthFailure) {
            _showCustomAlert(message: state.error, isSuccess: false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Bagian Header ---
                    _buildHeader(),

                    SizedBox(height: 60.h),

                    // --- Form Fields ---
                    _buildEmailField(),
                    SizedBox(height: 16.h),
                    _buildPasswordField(),
                    _buildForgotPasswordButton(),
                    SizedBox(height: 16.h),

                    // --- Action Buttons ---
                    _buildLoginButton(isLoading),
                    SizedBox(height: 24.h),
                    _buildDivider(),
                    SizedBox(height: 24.h),
                    _buildGoogleButton(isLoading),
                    SizedBox(height: 40.h),
                    _buildRegisterButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Selamat Datang!',
      textAlign: TextAlign.center,
      style: AppTheme.h2.copyWith(
        color: AppTheme.primaryColor,
        fontSize: 32.sp,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTheme.body1,
      decoration: _buildInputDecoration(hintText: 'Alamat Email'),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        }
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Masukkan format email yang valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      style: AppTheme.body1,
      decoration: _buildInputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textSecondaryColor,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Lupa Password?',
          style: AppTheme.body2.copyWith(fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        disabledBackgroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Login',
              style: AppTheme.button.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimaryColor,
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text('ATAU', style: AppTheme.caption),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () => context.read<AuthBloc>().add(AuthGoogleSignInRequested()),
      icon: Image.asset('assets/google_logo.png', height: 22.h),
      label: Text(
        'Masuk Dengan Google',
        style: AppTheme.body1.copyWith(fontSize: 14.sp),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.symmetric(vertical: 14.h),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextButton(
        onPressed: () => routes.pushNamed(RouteName.register),
        child: Text.rich(
          TextSpan(
            text: 'Belum Punya Akun? ',
            style: AppTheme.body2.copyWith(fontSize: 14.sp),
            children: [
              TextSpan(
                text: 'Daftar',
                style: AppTheme.subtitle2.copyWith(
                  color: AppTheme.primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [REFACTOR]: Membuat method DRY (Don't Repeat Yourself) untuk InputDecoration
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTheme.body2,
      filled: true,
      fillColor: AppTheme.surfaceColor,
      errorStyle: AppTheme.caption.copyWith(color: AppTheme.errorColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      suffixIcon: suffixIcon,
    );
  }
}
