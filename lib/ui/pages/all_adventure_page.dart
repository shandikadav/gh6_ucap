import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';

class AllAdventuresPage extends StatelessWidget {
  // [MODIFIKASI DATA]: Menambahkan key 'destination' untuk navigasi
  final adventures = [
    {
      'title': 'Simulasi Negosiasi Gaji',
      'tag': 'Karier',
      'icon': Icons.trending_up_rounded,
      'color': AppTheme.accentColor,
      'isLocked': false,
      'destination': const SalaryNegotiationPage(),
    },
    {
      'title': 'Studi Kasus Budgeting Bulanan',
      'tag': 'Keuangan',
      'icon': Icons.request_quote_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'destination': null,
    },
    {
      'title': 'Cara Menghadapi Diskriminasi',
      'tag': 'Sosial',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFF44336),
      'isLocked': true,
      'destination': null,
    },
    {
      'title': 'Latihan Wawancara User & HR',
      'tag': 'Karier',
      'icon': Icons.record_voice_over_rounded,
      'color': AppTheme.accentColor,
      'isLocked': true,
      'destination': null,
    },
    {
      'title': 'Manajemen Utang dan Pinjaman',
      'tag': 'Keuangan',
      'icon': Icons.credit_card_off_rounded,
      'color': AppTheme.successColor,
      'isLocked': true,
      'destination': null,
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
            destination: adventure['destination'] as Widget?,
          );
        },
      ),
    );
  }
}

class _VerticalAdventureCard extends StatelessWidget {
  final String title, tag;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final Widget? destination;

  const _VerticalAdventureCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.isLocked,
    this.destination,
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
          onTap: isLocked || destination == null
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination!),
                ),
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
                  Icon(Icons.lock_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
