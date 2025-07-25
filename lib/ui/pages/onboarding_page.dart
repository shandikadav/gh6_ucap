import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<String> titles = [
    'Belajar Soal Keuangan',
    'Belanja Bijak, Jangan Terjebak',
    'Buka Wawasan Lewat Cerita',
  ];

  List<String> subtitles = [
    'Belajar menabung, investasi kecil-kecilan, dan menghadapi realita finansial pasca keluar dari panti.',
    'Belajar mengelola pengeluaran dan mengenali jebakan gaya hidup yang sering tak terlihat.',
    'Belajar dari pengalaman virtual agar siap menghadapi dunia nyata tanpa pelindung.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 94.h),
                  CarouselSlider(
                    items: [
                      Image.asset('assets/img_onboarding1.png'),
                      Image.asset('assets/img_onboarding2.png'),
                      Image.asset('assets/img_onboarding3.png'),
                    ],
                    options: CarouselOptions(
                      height: 350.h,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                    carouselController: _carouselController,
                  ),
                  SizedBox(height: 60.h),
                  Column(
                    children: [
                      Text(
                        titles[currentIndex],
                        textAlign: TextAlign.center,
                        style: AppTheme.h3.copyWith(
                          color: AppTheme.textLightColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitles[currentIndex],
                        textAlign: TextAlign.center,
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textLightColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: titles.map((url) {
                          int index = titles.indexOf(url);
                          return Container(
                            width: currentIndex == index ? 38.w : 20.w,
                            height: 8.h,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 2.0,
                            ).r,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12.r),
                              color: currentIndex == index
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24).r,
              child: (currentIndex == 2)
                  ? ElevatedButton(
                      onPressed: () {
                        routes.goNamed(RouteName.register);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(372.w, 63.h),
                        backgroundColor: AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16).r,
                      ),
                      child: Text(
                        'Daftar',
                        style: AppTheme.button.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _carouselController.nextPage();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(372.w, 63.h),
                        backgroundColor: AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16).r,
                      ),
                      child: Text(
                        'Selanjutnya',
                        style: AppTheme.button.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
            ),
            TextButton(
              onPressed: () => routes.goNamed(RouteName.login),
              child: Text(
                'Skip',
                style: AppTheme.body1.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            SizedBox(height: 53.h),
          ],
        ),
      ),
    );
  }
}
