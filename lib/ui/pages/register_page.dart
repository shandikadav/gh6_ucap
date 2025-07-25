import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/bloc/auth/auth_bloc.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreedToPolicy = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          fullname: fullnameController.text.trim(),
          createdAt: DateTime.now().toString(),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showCustomAlert(message: state.message, isSuccess: true);
            Navigator.of(context).pop();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 40.h),
                    _buildFormFields(),
                    SizedBox(height: 16.h),
                    _buildPolicyCheckbox(),
                    SizedBox(height: 24.h),
                    _buildSignUpButton(isLoading),
                    SizedBox(height: 24.h),
                    _buildDivider(),
                    SizedBox(height: 24.h),
                    _buildGoogleButton(isLoading),
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
      'Buat Akun Barumu!',
      style: AppTheme.h2.copyWith(
        color: AppTheme.primaryColorDark,
        fontSize: 32.sp,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextFormField(
          controller: fullnameController,
          hintText: 'Nama Lengkap',
          validator: (value) => value == null || value.isEmpty
              ? 'Nama lengkap tidak boleh kosong'
              : null,
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: emailController,
          hintText: 'Alamat Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Email tidak boleh kosong';
            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
              return 'Masukkan format email yang valid';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextFormField(
          controller: passwordController,
          hintText: 'Password',
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Password tidak boleh kosong';
            if (value.length < 6) return 'Password minimal 6 karakter';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToPolicy,
          onChanged: (value) => setState(() => _agreedToPolicy = value!),
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Saya setuju dengan ',
              style: AppTheme.body2.copyWith(fontSize: 12.sp),
              children: [
                TextSpan(
                  text: 'Syarat & Ketentuan',
                  style: AppTheme.subtitle2.copyWith(
                    color: AppTheme.primaryColorDark,
                    fontSize: 12.sp,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: 'Kebijakan Privasi',
                  style: AppTheme.subtitle2.copyWith(
                    color: AppTheme.primaryColorDark,
                    fontSize: 12.sp,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(bool isLoading) {
    final bool canPress = !isLoading && _agreedToPolicy;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
      onPressed: canPress ? _register : null,
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text('Daftar', style: AppTheme.button.copyWith(fontSize: 16.sp)),
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
      onPressed: isLoading ? null : () {},
      icon: Image.asset('assets/google_logo.png', height: 24.h),
      label: Text(
        'Daftar Dengan Google',
        style: AppTheme.body1.copyWith(fontSize: 16.sp),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPrimaryColor,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
    );
  }

  Widget _buildTextFormField({
    required String hintText,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: AppTheme.body1,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _buildInputDecoration(
        hintText: hintText,
        isPassword: isPassword,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTheme.body2,
      filled: true,
      fillColor: Colors.grey.shade50,
      errorStyle: AppTheme.caption.copyWith(color: AppTheme.errorColor),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
    );
  }
}
