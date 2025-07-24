import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            _Header(),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32).r,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ContinueAdventureCard(),
                        SizedBox(height: 24.h),
                        _StoryCard(),
                        SizedBox(height: 24.h),
                        _CharacterStatusCard(),
                        SizedBox(height: 100.r),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk Header di bagian atas
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 60,
      ).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '☀️ Selamat Pagi!',
                style: AppTheme.body2.copyWith(color: AppTheme.textLightColor),
              ),
              Text(
                'Pona Wijaya',
                style: AppTheme.h1.copyWith(color: AppTheme.textLightColor),
              ),
            ],
          ),
          CircleAvatar(
            radius: 30.r,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),
        ],
      ),
    );
  }
}

/// Kartu utama untuk melanjutkan petualangan
class _ContinueAdventureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24).r,
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHAPTER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12).r,
                ),
                child: Text(
                  'Chapter 2',
                  style: AppTheme.caption.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 14.h),
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppTheme.redColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Image.asset('assets/avatar.png'),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Wawancara Kerja Pertamaku hihihiha',
                textAlign: TextAlign.center,
                style: AppTheme.h3.copyWith(color: Colors.white),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress Chapter',
                    style: AppTheme.caption.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '60%',
                    style: AppTheme.caption.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: Colors.white,
                minHeight: 6.h,
                borderRadius: BorderRadius.circular(3),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.play_arrow,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  'Lanjutkan Petualangan',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  foregroundColor: AppTheme.textPrimaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16).r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icon-book.png'),
              const SizedBox(width: 2),
              Text(
                'Cerita Terakhir',
                style: AppTheme.subtitle2.copyWith(
                  color: AppTheme.primaryColorDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"Terakhir kali, kamu baru saja mengirim email lamaran kerja ke 5 perusahaan berbeda. Deg-degan menunggu balasan, tiba-tiba teleponmu berdering..."',
            style: AppTheme.body2.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Kartu untuk menampilkan status karakter
class _CharacterStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text('Status Karaktermu', style: AppTheme.subtitle2),
            ],
          ),
          const SizedBox(height: 16),
          _StatusProgressBar(
            label: 'Keuangan',
            value: 0.6,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _StatusProgressBar(
            label: 'Kesehatan Mental',
            value: 0.6,
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 12),
          _StatusProgressBar(
            label: 'Energi',
            value: 0.6,
            color: AppTheme.primaryColorDark,
          ),
        ],
      ),
    );
  }
}

/// Widget progress bar kustom untuk status karakter
class _StatusProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatusProgressBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.body2.copyWith(color: AppTheme.textPrimaryColor),
            ),
            Text('${(value * 100).toInt()}%', style: AppTheme.body2),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withOpacity(0.2),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
