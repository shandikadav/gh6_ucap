// lib/pages/material_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';

class MaterialDetailPage extends StatelessWidget {
  final String materialTitle;
  final int expGained;
  final VoidCallback onComplete; // Callback baru

  const MaterialDetailPage({
    super.key,
    required this.materialTitle,
    required this.expGained,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text("Materi", style: AppTheme.h3),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(materialTitle, style: AppTheme.h2),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Konten materi akan ditampilkan di sini. ' * 50,
                    style: AppTheme.body1,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  'Selesaikan Materi',
                  style: AppTheme.button.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                onPressed: () {
                  // Panggil callback untuk update state di halaman sebelumnya
                  onComplete();

                  // Tampilkan notifikasi EXP
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selamat! Kamu mendapatkan $expGained XP ✨',
                      ),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );

                  // Kembali ke halaman daftar materi
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
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
