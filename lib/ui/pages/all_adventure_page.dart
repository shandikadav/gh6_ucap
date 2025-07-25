import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';

class AllAdventuresPage extends StatelessWidget {
  // [MODIFIKASI DATA]: Menambahkan key 'requiredArticles' dan status baca
  final adventures = [
    {
      'title': 'Simulasi Negosiasi Gaji',
      'tag': 'Karier',
      'icon': Icons.trending_up_rounded,
      'color': AppTheme.accentColor,
      'isLocked': false,
      'destination': const SalaryNegotiationPage(),
      'requiredArticles': <String>[], // Tidak ada artikel wajib
      'readCount': 0,
      'totalRequired': 0,
    },
    {
      'title': 'Studi Kasus Budgeting Bulanan',
      'tag': 'Keuangan',
      'icon': Icons.request_quote_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'destination': null,
      'requiredArticles': ['budget_bulanan'], // Artikel wajib
      'readCount': 1, // Sudah dibaca
      'totalRequired': 1,
    },
    {
      'title': 'Cara Menghadapi Diskriminasi',
      'tag': 'Sosial',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFF44336),
      'isLocked': true,
      'destination': null,
      'requiredArticles': <String>[],
      'readCount': 0,
      'totalRequired': 0,
    },
    {
      'title': 'Latihan Wawancara User & HR',
      'tag': 'Karier',
      'icon': Icons.record_voice_over_rounded,
      'color': AppTheme.accentColor,
      'isLocked': true,
      'destination': null,
      'requiredArticles': [
        'waspada_penipuan',
        'budget_bulanan',
      ], // Artikel wajib
      'readCount': 1, // Baru 1 yang dibaca
      'totalRequired': 2,
    },
    {
      'title': 'Manajemen Utang dan Pinjaman',
      'tag': 'Keuangan',
      'icon': Icons.credit_card_off_rounded,
      'color': AppTheme.successColor,
      'isLocked': true,
      'destination': null,
      'requiredArticles': <String>[],
      'readCount': 0,
      'totalRequired': 0,
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
          final readCount = adventure['readCount'] as int;
          final totalRequired = adventure['totalRequired'] as int;
          final areRequiredArticlesRead =
              totalRequired == 0 || readCount == totalRequired;

          return _VerticalAdventureCard(
            title: adventure['title'] as String,
            tag: adventure['tag'] as String,
            icon: adventure['icon'] as IconData,
            color: adventure['color'] as Color,
            isLocked: adventure['isLocked'] as bool,
            destination: adventure['destination'] as Widget?,
            readCount: readCount,
            totalRequired: totalRequired,
            areRequiredArticlesRead: areRequiredArticlesRead,
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
  final int readCount;
  final int totalRequired;
  final bool areRequiredArticlesRead;

  const _VerticalAdventureCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.isLocked,
    this.destination,
    required this.readCount,
    required this.totalRequired,
    required this.areRequiredArticlesRead,
  });

  @override
  Widget build(BuildContext context) {
    final canAccess =
        !isLocked && areRequiredArticlesRead && destination != null;

    return Opacity(
      opacity: canAccess ? 1.0 : 0.6,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: canAccess
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination!),
                )
              : () => _showRequirementDialog(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: IntrinsicHeight(
              // Tambahkan ini
              child: Column(
                mainAxisSize: MainAxisSize.min, // Tambahkan ini
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Ubah ke start
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: canAccess
                              ? LinearGradient(
                                  colors: [color.withOpacity(0.5), color],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: canAccess ? null : Colors.grey.shade300,
                        ),
                        child: Icon(
                          icon,
                          size: 24.sp,
                          color: canAccess
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // Tambahkan ini
                          children: [
                            Text(
                              title,
                              style: AppTheme.subtitle2,
                              maxLines: 2, // Batasi lines
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              tag,
                              style: AppTheme.caption.copyWith(color: color),
                            ),
                          ],
                        ),
                      ),
                      if (isLocked)
                        Icon(Icons.lock_rounded, color: Colors.grey.shade400)
                      else if (!areRequiredArticlesRead)
                        Icon(
                          Icons.article_outlined,
                          color: Colors.orange.shade400,
                        ),
                    ],
                  ),

                  // Progress artikel wajib jika ada
                  if (totalRequired > 0) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: areRequiredArticlesRead
                            ? AppTheme.successColor.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            areRequiredArticlesRead
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: areRequiredArticlesRead
                                ? AppTheme.successColor
                                : Colors.orange,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              areRequiredArticlesRead
                                  ? 'Semua artikel wajib sudah dibaca ✓'
                                  : '$readCount dari $totalRequired artikel wajib',
                              style: AppTheme.caption.copyWith(
                                color: areRequiredArticlesRead
                                    ? AppTheme.successColor
                                    : Colors.orange,
                              ),
                              maxLines: 2, // Batasi lines
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRequirementDialog(BuildContext context) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Petualangan ini masih terkunci'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } else if (!areRequiredArticlesRead) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text('Artikel Wajib', style: AppTheme.h3),
          content: SingleChildScrollView(
            // Tambahkan scroll view
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Baca artikel wajib di Pojok Info untuk membuka petualangan ini.',
                  style: AppTheme.body2,
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Progress: $readCount dari $totalRequired artikel',
                    style: AppTheme.caption.copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigasi ke Pojok Info akan diimplementasi'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text('Ke Pojok Info'),
            ),
          ],
        ),
      );
    }
  }
}
