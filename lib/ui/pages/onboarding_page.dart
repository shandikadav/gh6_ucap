import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipPath(
                clipper: OnboardingClipper(),
                child: Container(
                  height: screenSize.height * 0.55.h,
                  width: double.infinity,
                  color: AppTheme.primaryColor,
                ),
              ),

              Positioned.fill(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light,
                  child: Container(),
                ),
              ),

              Positioned(
                top: screenSize.height * 0.15.r,
                child: Image.asset(
                  'assets/onboarding_illustration.png',
                  width: screenSize.width * 0.7.w,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0).r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),

                  Text(
                    'Pilihanmu, Ceritamu',
                    textAlign: TextAlign.center,
                    style: AppTheme.h2.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'Setiap keputusan ada di tanganmu. Jadikan ini tempatmu berlatih mengambil langkah-langkah penting untuk masa depanmu.',
                    textAlign: TextAlign.center,
                    style: AppTheme.body2,
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      routes.goNamed(RouteName.register);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16).r,
                    ),
                    child: Text(
                      'Daftar',
                      style: AppTheme.button.copyWith(fontSize: 16.sp),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Link Log In
                  Text.rich(
                    TextSpan(
                      text: 'Sudah Punya Akun? ',
                      style: AppTheme.body2.copyWith(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: AppTheme.body2.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              routes.goNamed(RouteName.login);
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomClipper untuk membuat bentuk lengkungan pada background.
class OnboardingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.85);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.85,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
