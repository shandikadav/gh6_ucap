// lib/pages/category_detail_page.dart

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

import 'package:gh6_ucap/themes/theme.dart';
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
  late List<Map<String, dynamic>> _materials;
  late ConfettiController _confettiController;
  int _totalExpGained = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _materials = _getMaterialsForCategory(widget.categoryId);
    _totalExpGained = _materials.fold(
      0,
      (sum, item) => sum + (item['exp'] as int),
    );
  }

  // Data dummy terpusat
  List<Map<String, dynamic>> _getMaterialsForCategory(String categoryId) {
    final allMaterials = {
      'keuangan': [
        {
          'id': 'k1',
          'title': 'Cara Membuat Anggaran Bulanan',
          'type': 'artikel',
          'exp': 20,
          'isCompleted': false,
        },
        {
          'id': 'k2',
          'title': 'Video: Investasi untuk Pemula',
          'type': 'video',
          'exp': 35,
          'isCompleted': false,
        },
        {
          'id': 'k3',
          'title': 'Memahami Dana Darurat',
          'type': 'artikel',
          'exp': 25,
          'isCompleted': false,
        },
      ],
      'karier': [
        {
          'id': 'c1',
          'title': 'Tips Membuat CV ATS-Friendly',
          'type': 'artikel',
          'exp': 20,
          'isCompleted': false,
        },
        {
          'id': 'c2',
          'title': 'Menjawab Pertanyaan Interview Sulit',
          'type': 'video',
          'exp': 40,
          'isCompleted': false,
        },
      ],
      'mental': [
        {
          'id': 'm1',
          'title': 'Mengatasi Burnout di Tempat Kerja',
          'type': 'artikel',
          'exp': 30,
          'isCompleted': false,
        },
      ],
    };
    return allMaterials[categoryId] ?? [];
  }

  void _markMaterialAsCompleted(String materialId) {
    setState(() {
      final index = _materials.indexWhere((m) => m['id'] == materialId);
      if (index != -1) {
        _materials[index]['isCompleted'] = true;
      }
    });

    // Cek apakah semua materi sudah selesai
    final allCompleted = _materials.every((m) => m['isCompleted'] == true);
    if (allCompleted) {
      _confettiController.play();
      _showModuleCompletedDialog(context);
      widget
          .onModuleCompleted(); // Panggil callback untuk buka modul selanjutnya
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: AppTheme.h3),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            itemCount: _materials.length,
            itemBuilder: (context, index) {
              final material = _materials[index];
              // Materi terkunci jika materi sebelumnya belum selesai
              final bool isLocked =
                  index > 0 && !_materials[index - 1]['isCompleted'];

              return _MaterialCard(
                title: material['title'] as String,
                type: material['type'] as String,
                exp: material['exp'] as int,
                isCompleted: material['isCompleted'] as bool,
                isLocked: isLocked,
                color: widget.categoryColor,
                onTap: () {
                  if (!isLocked) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialDetailPage(
                          materialTitle: material['title'] as String,
                          expGained: material['exp'] as int,
                          // Kirim callback untuk menandai selesai
                          onComplete: () => _markMaterialAsCompleted(
                            material['id'] as String,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
          ),
        ],
      ),
    );
  }

  void _showModuleCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Column(
          children: [
            Icon(
              Icons.stars_rounded,
              color: AppTheme.primaryColor,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Modul Selesai!',
              textAlign: TextAlign.center,
              style: AppTheme.h3,
            ),
          ],
        ),
        content: Text(
          'Kerja bagus! Kamu telah menyelesaikan modul "${widget.categoryTitle}" dan mendapatkan total $_totalExpGained EXP. Modul berikutnya sekarang terbuka.',
          textAlign: TextAlign.center,
          style: AppTheme.body2,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Lanjutkan Petualangan',
                style: AppTheme.button.copyWith(
                  color: AppTheme.primaryColorDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String title, type;
  final int exp;
  final bool isCompleted, isLocked;
  final Color color;
  final VoidCallback onTap;

  const _MaterialCard({
    required this.title,
    required this.type,
    required this.exp,
    required this.isCompleted,
    required this.isLocked,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isCompleted
                ? color.withOpacity(0.15)
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              if (!isLocked)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
            ],
            border: Border.all(
              color: isCompleted ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade300
                      : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isLocked
                      ? Icons.lock_rounded
                      : (type == 'artikel'
                            ? Icons.article_rounded
                            : Icons.play_circle_filled_rounded),
                  color: isLocked ? Colors.grey.shade500 : color,
                  size: 28.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.subtitle2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isLocked) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '+$exp XP',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Icon(Icons.check_circle_rounded, color: color, size: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}
