// lib/pages/pojok_info_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gh6_ucap/themes/theme.dart';

import 'category_detail_page.dart';

class PojokInfoPage extends StatefulWidget {
  const PojokInfoPage({super.key});

  @override
  State<PojokInfoPage> createState() => _PojokInfoPageState();
}

class _PojokInfoPageState extends State<PojokInfoPage> {
  // Data kategori sekarang menjadi bagian dari state untuk bisa diubah
  late List<Map<String, dynamic>> categories;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal
    categories = [
      {
        'id': 'keuangan',
        'title': 'Manajemen Keuangan',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.successColor,
        'isLocked': false, // Kategori pertama selalu terbuka
      },
      {
        'id': 'karier',
        'title': 'Persiapan Karier',
        'icon': Icons.work_rounded,
        'color': AppTheme.accentColor,
        'isLocked': true, // Terkunci di awal
      },
      {
        'id': 'mental',
        'title': 'Kesehatan Mental',
        'icon': Icons.psychology_alt_rounded,
        'color': const Color(0xFFFF9800),
        'isLocked': true, // Terkunci di awal
      },
    ];
  }

  // Callback function untuk membuka kategori berikutnya
  void _unlockNextCategory(String completedCategoryId) {
    final completedIndex = categories.indexWhere(
      (cat) => cat['id'] == completedCategoryId,
    );

    // Jika masih ada kategori berikutnya, buka kuncinya
    if (completedIndex != -1 && completedIndex + 1 < categories.length) {
      setState(() {
        categories[completedIndex + 1]['isLocked'] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Pojok Info', style: AppTheme.h3),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _buildHeaderCard(),
          SizedBox(height: 24.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _CategoryCard(
                      title: category['title'] as String,
                      icon: category['icon'] as IconData,
                      color: category['color'] as Color,
                      isLocked: category['isLocked'] as bool,
                      onTap: () {
                        if (!(category['isLocked'] as bool)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                categoryId: category['id'] as String,
                                categoryTitle: category['title'] as String,
                                categoryColor: category['color'] as Color,
                                // Kirim callback function ke halaman detail
                                onModuleCompleted: () {
                                  _unlockNextCategory(category['id'] as String);
                                },
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selesaikan modul sebelumnya terlebih dahulu!',
                              ),
                              backgroundColor: AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [AppTheme.primaryColorDark, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang di Pojok Info!',
            style: AppTheme.h3.copyWith(color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            'Selesaikan semua materi secara berurutan untuk membuka modul baru.',
            style: AppTheme.body2.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isLocked ? Colors.grey.shade300 : color.withOpacity(0.2),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.shade400 : color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.w),
                ),
                const Spacer(),
                Text(
                  title,
                  style: AppTheme.subtitle2.copyWith(
                    color: isLocked
                        ? Colors.grey.shade600
                        : AppTheme.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Modul ${isLocked ? "Terkunci" : "Tersedia"}',
                  style: AppTheme.caption.copyWith(
                    color: isLocked
                        ? Colors.grey.shade500
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            if (isLocked)
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 60.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
