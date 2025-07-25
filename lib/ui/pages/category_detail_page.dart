import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/models/article_progress.dart';
import 'material_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final Color categoryColor;
  final VoidCallback onModuleCompleted;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryColor,
    required this.onModuleCompleted,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late List<Map<String, dynamic>> materials;

  @override
  void initState() {
    super.initState();
    materials = _getMaterialsForCategory(widget.categoryId);
  }

  List<Map<String, dynamic>> _getMaterialsForCategory(String categoryId) {
    switch (categoryId) {
      case 'keuangan':
        return [
          {
            'id': 'budget_bulanan',
            'title': 'Cara Membuat Budget Bulanan yang Realistis',
            'subtitle': 'Panduan lengkap mengelola keuangan bulanan',
            'exp': 50,
            'isCompleted': ArticleProgress.isArticleRead('budget_bulanan'),
            'isRequired': true, // Artikel wajib untuk Chapter 2
            'estimatedTime': '5 menit',
          },
          {
            'id': 'investasi_pemula',
            'title': 'Panduan Investasi untuk Pemula',
            'subtitle': 'Mulai investasi dengan modal kecil',
            'exp': 75,
            'isCompleted': ArticleProgress.isArticleRead('investasi_pemula'),
            'isRequired': false,
            'estimatedTime': '8 menit',
          },
          {
            'id': 'menabung_efektif',
            'title': 'Tips Menabung yang Efektif',
            'subtitle': 'Strategi menabung untuk masa depan',
            'exp': 60,
            'isCompleted': ArticleProgress.isArticleRead('menabung_efektif'),
            'isRequired': false,
            'estimatedTime': '6 menit',
          },
        ];
      case 'karier':
        return [
          {
            'id': 'waspada_penipuan',
            'title': 'Waspada Penipuan Lowongan Kerja',
            'subtitle': 'Kenali ciri-ciri lowongan kerja palsu',
            'exp': 60,
            'isCompleted': ArticleProgress.isArticleRead('waspada_penipuan'),
            'isRequired': true, // Artikel wajib untuk Chapter 2
            'estimatedTime': '7 menit',
          },
          {
            'id': 'tips_wawancara',
            'title': 'Tips Sukses Wawancara Kerja',
            'subtitle': 'Persiapan menghadapi wawancara',
            'exp': 80,
            'isCompleted': ArticleProgress.isArticleRead('tips_wawancara'),
            'isRequired': false,
            'estimatedTime': '10 menit',
          },
          {
            'id': 'cv_menarik',
            'title': 'Membuat CV yang Menarik',
            'subtitle': 'Template dan tips menulis CV',
            'exp': 70,
            'isCompleted': ArticleProgress.isArticleRead('cv_menarik'),
            'isRequired': false, // Will be required for Chapter 3
            'estimatedTime': '8 menit',
          },
          {
            'id': 'networking_profesional',
            'title': 'Membangun Networking Profesional',
            'subtitle': 'Cara membangun relasi kerja yang baik',
            'exp': 65,
            'isCompleted': ArticleProgress.isArticleRead(
              'networking_profesional',
            ),
            'isRequired': false, // Will be required for Chapter 3
            'estimatedTime': '6 menit',
          },
        ];
      default:
        return [];
    }
  }

  void _markMaterialAsCompleted(String materialId) {
    setState(() {
      final index = materials.indexWhere((m) => m['id'] == materialId);
      if (index != -1) {
        materials[index]['isCompleted'] = true;
        // Update global state
        ArticleProgress.markArticleAsRead(materialId);
      }
    });

    final allCompleted = materials.every((m) => m['isCompleted'] == true);
    if (allCompleted) {
      widget.onModuleCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = ArticleProgress.getCurrentChapter();
    final requiredArticles =
        ArticleProgress.getRequiredArticlesForCurrentChapter();

    // Filter materials for current chapter requirements
    final requiredMaterials = materials
        .where(
          (m) => requiredArticles.contains(m['id']) || m['isRequired'] == true,
        )
        .toList();
    final otherMaterials = materials
        .where(
          (m) =>
              !requiredArticles.contains(m['id']) && m['isRequired'] == false,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: AppTheme.h3),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Header dengan info artikel wajib
          if (requiredMaterials.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: widget.categoryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: widget.categoryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Artikel Wajib - ${_getChapterName(currentChapter)}',
                        style: AppTheme.subtitle2.copyWith(
                          color: widget.categoryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Baca artikel ini untuk melanjutkan petualangan',
                    style: AppTheme.caption.copyWith(
                      color: widget.categoryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Artikel wajib
            ...requiredMaterials.map(
              (material) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: _MaterialCard(
                  material: material,
                  categoryColor: widget.categoryColor,
                  isRequired: true,
                  onTap: () => _navigateToMaterial(material),
                ),
              ),
            ),

            SizedBox(height: 24.h),
            Text('Artikel Lainnya', style: AppTheme.subtitle1),
            SizedBox(height: 12.h),
          ],

          // Artikel lainnya
          ...otherMaterials.map(
            (material) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: _MaterialCard(
                material: material,
                categoryColor: widget.categoryColor,
                isRequired: false,
                onTap: () => _navigateToMaterial(material),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChapterName(String currentChapter) {
    switch (currentChapter) {
      case 'chapter_2_preparation':
      case 'chapter_2':
        return 'Chapter 2';
      case 'chapter_3':
        return 'Chapter 3';
      default:
        return 'Chapter 2';
    }
  }

  void _navigateToMaterial(Map<String, dynamic> material) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialDetailPage(
          materialTitle: material['title'],
          expGained: material['exp'],
          onComplete: () => _markMaterialAsCompleted(material['id']),
        ),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  final Color categoryColor;
  final bool isRequired;
  final VoidCallback onTap;

  const _MaterialCard({
    required this.material,
    required this.categoryColor,
    required this.isRequired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = material['isCompleted'] as bool;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isRequired
                ? categoryColor.withOpacity(0.5)
                : Colors.grey.shade200,
            width: isRequired ? 2 : 1,
          ),
        ),
        child: IntrinsicHeight(
          // Tambahkan ini untuk fix overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Ubah ke start
            children: [
              // Status icon
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successColor.withOpacity(0.1)
                      : categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.article_rounded,
                  color: isCompleted ? AppTheme.successColor : categoryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Tambahkan ini
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material['title'],
                            style: AppTheme.subtitle2.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? Colors.grey
                                  : AppTheme.textPrimaryColor,
                            ),
                            maxLines: 2, // Batasi lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'WAJIB',
                              style: AppTheme.caption.copyWith(
                                color: categoryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      material['subtitle'],
                      style: AppTheme.caption.copyWith(
                        color: isCompleted
                            ? Colors.grey
                            : AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2, // Batasi lines
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    // Wrap dalam Flexible untuk mencegah overflow
                    Flexible(
                      child: Wrap(
                        spacing: 16.w,
                        runSpacing: 4.h,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                material['estimatedTime'],
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_outline,
                                size: 14.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${material['exp']} XP',
                                style: AppTheme.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (isCompleted)
                            Text(
                              'Selesai ✓',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
