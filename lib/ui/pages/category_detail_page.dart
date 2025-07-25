import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gh6_ucap/models/articles_model.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/services/article_service.dart';
import 'material_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final ArticleCategory category;
  final VoidCallback onArticleCompleted;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.onArticleCompleted,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final ArticleService _articleService = ArticleService();
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final articlesData = await _articleService.getArticlesByCategory(
        widget.category.id,
      );
      if (mounted) {
        setState(() {
          articles = articlesData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading articles: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(widget.category.colorHex.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.category.name, style: AppTheme.h3),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
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
                    _getIconFromName(widget.category.iconName),
                    color: Colors.white,
                    size: 32.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: AppTheme.h2.copyWith(fontSize: 24.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.category.description,
                        style: AppTheme.body2.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Articles List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: color))
                : articles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64.w,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text('Belum ada artikel dalam kategori ini'),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _DynamicArticleCard(
                                articleData: articles[index],
                                categoryColor: color,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaterialDetailPage(
                                        articleId:
                                            articles[index]['article'].id,
                                        materialTitle:
                                            articles[index]['article'].title,
                                        materialContent:
                                            articles[index]['article'].content,
                                        materialType:
                                            articles[index]['article'].type,
                                        expGained: articles[index]['article']
                                            .expReward,
                                        onComplete: () async {
                                          await _articleService.completeArticle(
                                            articles[index]['article'].id,
                                          );
                                          _loadArticles();
                                          widget.onArticleCompleted();
                                        },
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
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'work': Icons.work_rounded,
      'account_balance_wallet': Icons.account_balance_wallet_rounded,
      'groups': Icons.groups_rounded,
      'lightbulb': Icons.lightbulb_rounded,
    };
    return iconMap[iconName] ?? Icons.article_rounded;
  }
}

class _DynamicArticleCard extends StatelessWidget {
  final Map<String, dynamic> articleData;
  final Color categoryColor;
  final VoidCallback onTap;

  const _DynamicArticleCard({
    required this.articleData,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Article article = articleData['article'];
    final bool isCompleted = articleData['isCompleted'];

    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Type Icon
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: article.type == 'video'
                        ? Colors.red.withOpacity(0.2)
                        : categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    article.type == 'video'
                        ? Icons.play_circle_filled
                        : Icons.article,
                    color: article.type == 'video' ? Colors.red : categoryColor,
                    size: 24.w,
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
                              article.title,
                              style: AppTheme.subtitle1.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (isCompleted)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20.w,
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.w,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${article.readTime} menit',
                            style: AppTheme.caption,
                          ),
                          SizedBox(width: 12.w),
                          Icon(Icons.stars, size: 14.w, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            '+${article.expReward} EXP',
                            style: AppTheme.caption.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
      ),
    );
  }
}
