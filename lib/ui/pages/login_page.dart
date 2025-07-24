import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              Text(
                'Selamat Datang!',
                textAlign: TextAlign.center,
                style: AppTheme.h2.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 32.sp,
                ),
              ),

              SizedBox(height: 60.h),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.body1,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: AppTheme.body2,
                  filled: true,

                  fillColor: AppTheme.backgroundColor.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16).r,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ).r,
                ),
              ),

              SizedBox(height: 16.h),

              // Input field untuk Password
              TextFormField(
                obscureText: true,
                style: AppTheme.body1,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: AppTheme.body2,
                  filled: true,
                  fillColor: AppTheme.backgroundColor.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16).r,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ).r,
                ),
              ),

              SizedBox(height: 8.h),

              // Tombol "Forgot Password?"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Handle logic lupa password
                  },
                  child: Text('Forgot Password?', style: AppTheme.body2),
                ),
              ),

              SizedBox(height: 16.h),

              // Tombol "LOGIN"
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle logic login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16).r,
                ),
                child: Text(
                  'LOGIN',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.textLightColor,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Tombol "CONTINUE WITH GOOGLE"
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Handle logic sign in dengan Google
                },
                icon: Image.asset('assets/google_logo.png', height: 22.h),
                label: Text(
                  'CONTINUE WITH GOOGLE',
                  style: AppTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50).r,
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14).r,
                ),
              ),

              SizedBox(height: 60.h),

              // Teks untuk sign up
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    routes.pushNamed(RouteName.register);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    overlayColor: Colors.transparent,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'DON\'T HAVE AN ACCOUNT? ',
                      style: AppTheme.body2.copyWith(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: 'SIGN UP',
                          style: AppTheme.subtitle2.copyWith(
                            color: AppTheme.primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
