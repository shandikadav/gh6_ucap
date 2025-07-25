import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gh6_ucap/models/articles_model.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/services/article_service.dart';
import 'category_detail_page.dart';

class PojokInfoPage extends StatefulWidget {
  const PojokInfoPage({super.key});

  @override
  State<PojokInfoPage> createState() => _PojokInfoPageState();
}

class _PojokInfoPageState extends State<PojokInfoPage> {
  final ArticleService _articleService = ArticleService();
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await _articleService.getCategoriesWithStatus();
      if (mounted) {
        setState(() {
          categories = categoriesData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Pojok Info', style: AppTheme.h2),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await _articleService.seedArticles();
              _loadCategories();
            },
            tooltip: 'Seed Articles (Dev)',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64.w, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text('Belum ada kategori tersedia'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () async {
                          await _articleService.seedArticles();
                          _loadCategories();
                        },
                        child: Text('Muat Konten'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _CategoryCard(
                                categoryData: categories[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryDetailPage(
                                        category: categories[index]['category'],
                                        onArticleCompleted: _loadCategories,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> categoryData;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryData,
    required this.onTap,
  });

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'work': Icons.work_rounded,
      'account_balance_wallet': Icons.account_balance_wallet_rounded,
      'groups': Icons.groups_rounded,
      'lightbulb': Icons.lightbulb_rounded,
    };
    return iconMap[iconName] ?? Icons.article_rounded;
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ArticleCategory category = categoryData['category'];
    final int totalArticles = categoryData['totalArticles'];
    final int completedCount = categoryData['completedCount'];
    final int completionPercentage = categoryData['completionPercentage'];
    final Color color = _getColorFromHex(category.colorHex);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.7), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  _getIconFromName(category.iconName),
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTheme.h3.copyWith(fontSize: 18.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      category.description,
                      style: AppTheme.body2.copyWith(color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    // Progress
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: completionPercentage / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '$completedCount/$totalArticles',
                          style: AppTheme.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$completionPercentage% selesai',
                      style: AppTheme.caption.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}