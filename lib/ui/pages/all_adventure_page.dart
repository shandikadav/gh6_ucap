import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';
import 'package:go_router/go_router.dart';

class AllAdventuresPage extends StatelessWidget {
  final adventures = [
    {
      'title': 'Simulasi Negosiasi Gaji',
      'tag': 'Karier',
      'icon': Icons.trending_up_rounded,
      'color': AppTheme.accentColor,
      'isLocked': false,
      'scenarioTitle': 'Negosiasi Gaji',
      'category': 'Karier',
    },
    {
      'title': 'Studi Kasus Budgeting Bulanan',
      'tag': 'Keuangan',
      'icon': Icons.request_quote_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'scenarioTitle': 'Budgeting Bulanan',
      'category': 'Keuangan',
    },
    {
      'title': 'Cara Menghadapi Diskriminasi',
      'tag': 'Sosial',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFF44336),
      'isLocked': false,
      'scenarioTitle': 'Menghadapi Diskriminasi',
      'category': 'Sosial',
    },
    {
      'title': 'Latihan Wawancara User & HR',
      'tag': 'Karier',
      'icon': Icons.record_voice_over_rounded,
      'color': AppTheme.accentColor,
      'isLocked': false,
      'scenarioTitle': 'Wawancara Kerja',
      'category': 'Karier',
    },
    {
      'title': 'Mencari Tempat Tinggal',
      'tag': 'Keuangan',
      'icon': Icons.home_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'scenarioTitle': 'Mencari Tempat Tinggal',
      'category': 'Lifestyle',
    },
    {
      'title': 'Manajemen Utang dan Pinjaman',
      'tag': 'Keuangan',
      'icon': Icons.credit_card_off_rounded,
      'color': AppTheme.successColor,
      'isLocked': true,
      'scenarioTitle': 'Manajemen Utang',
      'category': 'Keuangan',
    },
  ];

  AllAdventuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Semua Petualangan', style: AppTheme.h3),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: adventures.length,
        itemBuilder: (context, index) {
          final adventure = adventures[index];
          return _VerticalAdventureCard(
            title: adventure['title'] as String,
            tag: adventure['tag'] as String,
            icon: adventure['icon'] as IconData,
            color: adventure['color'] as Color,
            isLocked: adventure['isLocked'] as bool,
            scenarioTitle: adventure['scenarioTitle'] as String,
            category: adventure['category'] as String,
          );
        },
      ),
    );
  }
}

class _VerticalAdventureCard extends StatelessWidget {
  final String title, tag, scenarioTitle, category;
  final IconData icon;
  final Color color;
  final bool isLocked;

  const _VerticalAdventureCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.scenarioTitle,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: isLocked
              ? () {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('🔒 Petualangan ini belum terbuka!'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                }
              : () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(
                    RouteName.adventure,
                    pathParameters: {
                      'scenarioTitle': Uri.encodeComponent(scenarioTitle),
                      'category': Uri.encodeComponent(category),
                    },
                  );
                },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: isLocked
                        ? null
                        : LinearGradient(
                            colors: [color.withOpacity(0.5), color],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isLocked ? Colors.grey.shade300 : null,
                  ),
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: isLocked ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.subtitle2),
                      SizedBox(height: 4.h),
                      Text(tag, style: AppTheme.caption.copyWith(color: color)),
                    ],
                  ),
                ),
                if (isLocked)
                  Icon(Icons.lock_rounded, color: Colors.grey.shade400)
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 16.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
