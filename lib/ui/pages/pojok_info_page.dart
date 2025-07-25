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
  // Data kategori dengan artikel wajib untuk petualangan
  late List<Map<String, dynamic>> categories;

  @override
  void initState() {
    super.initState();
    categories = [
      {
        'id': 'keuangan',
        'title': 'Manajemen Keuangan',
        'subtitle': 'Dasar pengelolaan uang',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.successColor,
        'isLocked': false,
        'progress': 0.7, // 70% complete
        'totalArticles': 3,
        'completedArticles': 2,
        'hasRequiredArticles': true, // Ada artikel wajib untuk petualangan
        'requiredBadge': 'WAJIB CHAPTER 2',
      },
      {
        'id': 'karier',
        'title': 'Persiapan Karier',
        'subtitle': 'Tips sukses berkarier',
        'icon': Icons.work_rounded,
        'color': AppTheme.accentColor,
        'isLocked': false,
        'progress': 0.5, // 50% complete
        'totalArticles': 4,
        'completedArticles': 2,
        'hasRequiredArticles': true, // Ada artikel wajib untuk petualangan
        'requiredBadge': 'WAJIB CHAPTER 2',
      },
      {
        'id': 'mental',
        'title': 'Kesehatan Mental',
        'subtitle': 'Jaga mental tetap sehat',
        'icon': Icons.psychology_alt_rounded,
        'color': const Color(0xFFFF9800),
        'isLocked': true,
        'progress': 0.0,
        'totalArticles': 5,
        'completedArticles': 0,
        'hasRequiredArticles': false,
        'requiredBadge': '',
      },
      {
        'id': 'sosial',
        'title': 'Kehidupan Sosial',
        'subtitle': 'Berinteraksi dengan baik',
        'icon': Icons.groups_rounded,
        'color': const Color(0xFFF44336),
        'isLocked': true,
        'progress': 0.0,
        'totalArticles': 3,
        'completedArticles': 0,
        'hasRequiredArticles': false,
        'requiredBadge': '',
      },
    ];
  }

  void _unlockNextCategory(String completedCategoryId) {
    final completedIndex = categories.indexWhere(
      (cat) => cat['id'] == completedCategoryId,
    );

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
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _buildHeaderCard(),
          SizedBox(height: 24.h),

          // Progress overview
          _buildProgressOverview(),
          SizedBox(height: 24.h),

          // Categories grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 2.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 1,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _CategoryCard(
                      category: category,
                      onTap: () {
                        if (!(category['isLocked'] as bool)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                categoryId: category['id'] as String,
                                categoryTitle: category['title'] as String,
                                categoryColor: category['color'] as Color,
                                onModuleCompleted: () {
                                  _unlockNextCategory(category['id'] as String);
                                },
                              ),
                            ),
                          );
                        } else {
                          _showLockedCategoryDialog(context);
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [AppTheme.primaryColorDark, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Pojok Info',
                style: AppTheme.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Baca artikel untuk membuka petualangan baru!',
            style: AppTheme.body2.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    final totalCompleted = categories.fold<int>(
      0,
      (sum, cat) => sum + (cat['completedArticles'] as int),
    );
    final totalArticles = categories.fold<int>(
      0,
      (sum, cat) => sum + (cat['totalArticles'] as int),
    );
    final overallProgress = totalArticles > 0
        ? totalCompleted / totalArticles
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress Keseluruhan', style: AppTheme.subtitle2),
              Text(
                '$totalCompleted/$totalArticles artikel',
                style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.primaryColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  void _showLockedCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Kategori Terkunci', style: AppTheme.h3),
        content: Text(
          'Selesaikan kategori sebelumnya untuk membuka kategori ini.',
          style: AppTheme.body2,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = category['isLocked'] as bool;
    final hasRequiredArticles = category['hasRequiredArticles'] as bool;
    final progress = category['progress'] as double;
    final completedArticles = category['completedArticles'] as int;
    final totalArticles = category['totalArticles'] as int;
    final requiredBadge = category['requiredBadge'] as String;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade100 : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isLocked
                ? Colors.grey.shade300
                : hasRequiredArticles
                ? (category['color'] as Color).withOpacity(0.5)
                : Colors.grey.shade200,
            width: hasRequiredArticles && !isLocked ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.grey.shade400
                        : (category['color'] as Color),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category['title'] as String,
                              style: AppTheme.subtitle2.copyWith(
                                color: isLocked
                                    ? Colors.grey.shade600
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          if (hasRequiredArticles && !isLocked)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: (category['color'] as Color).withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                requiredBadge,
                                style: AppTheme.caption.copyWith(
                                  color: category['color'] as Color,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        category['subtitle'] as String,
                        style: AppTheme.caption.copyWith(
                          color: isLocked
                              ? Colors.grey.shade500
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Progress
                      if (!isLocked) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress', style: AppTheme.caption),
                            Text(
                              '$completedArticles/$totalArticles artikel',
                              style: AppTheme.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: (category['color'] as Color)
                              .withOpacity(0.2),
                          color: category['color'] as Color,
                          minHeight: 4.h,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ] else ...[
                        Text(
                          'Kategori Terkunci',
                          style: AppTheme.caption.copyWith(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Lock overlay
            if (isLocked)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
