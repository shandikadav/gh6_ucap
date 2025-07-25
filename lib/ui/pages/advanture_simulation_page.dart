import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:gh6_ucap/models/article_progress.dart';

class SalaryNegotiationPage extends StatefulWidget {
  const SalaryNegotiationPage({super.key});

  @override
  State<SalaryNegotiationPage> createState() => _SalaryNegotiationPageState();
}

class _SalaryNegotiationPageState extends State<SalaryNegotiationPage>
    with TickerProviderStateMixin {
  // --- STATE MANAGEMENT ---
  int _currentStep = 0;
  int _lives = 3;
  String? _selectedOptionId;
  final TextEditingController _reasonController = TextEditingController();
  late final List<Map<String, dynamic>> _simulationScript;

  // --- ANIMATION CONTROLLERS ---
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _simulationScript = _getSimulationData();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  // --- DATA DUMMY UNTUK SIMULASI ---
  List<Map<String, dynamic>> _getSimulationData() {
    return [
      {
        'id': 1,
        'character': 'Narator',
        'avatar': 'assets/avatar.png', // Ganti dengan path aset Anda
        'scenario':
            'Setelah proses interview yang panjang, kamu akhirnya menerima email berisi penawaran kerja (offering letter) dari Perusahaan Impian. Gaji yang ditawarkan adalah Rp 5.000.000 per bulan. Angka ini sedikit di bawah ekspektasimu.',
        'options': [],
      },
      {
        'id': 2,
        'character': 'Manajer HR',
        'avatar': 'assets/hr_manager.png', // Ganti dengan path aset Anda
        'scenario':
            'Manajer HR meneleponmu, "Halo, selamat ya! Kami sangat senang bisa memberikan penawaran ini. Bagaimana tanggapanmu?"',
        'options': [
          {
            'id': 'A',
            'text':
                'Langsung menerima tawaran tersebut karena takut kehilangan kesempatan.',
            'isCorrect': false,
          },
          {
            'id': 'B',
            'text':
                'Mengucapkan terima kasih dan meminta waktu untuk mempertimbangkan tawaran tersebut.',
            'isCorrect': true,
          },
        ],
        'insightCorrect':
            'Tindakan yang sangat profesional! Meminta waktu menunjukkan bahwa kamu mempertimbangkan segala sesuatunya dengan matang dan tidak terburu-buru.',
        'insightIncorrect':
            'Meskipun aman, menerima tawaran di bawah ekspektasi tanpa negosiasi bisa membuatmu tidak puas di kemudian hari. Selalu ada ruang untuk diskusi.',
      },
      {
        'id': 3,
        'character': 'Manajer HR',
        'avatar': 'assets/hr_manager.png',
        'scenario':
            'Setelah kamu mengirim email untuk negosiasi, Manajer HR bertanya, "Baik, boleh jelaskan berapa ekspektasi gaji yang kamu harapkan dan apa alasannya?"',
        'options': [
          {
            'id': 'A',
            'text':
                'Menyebutkan angka yang jauh lebih tinggi (misal, 8 juta) dengan harapan bisa ditawar.',
            'isCorrect': false,
          },
          {
            'id': 'B',
            'text':
                'Menyebutkan rentang gaji yang masuk akal (misal, 5.5 - 6.5 juta) disertai riset UMR dan skill yang dimiliki.',
            'isCorrect': true,
          },
        ],
        'insightCorrect':
            'Jawaban cerdas! Memberikan rentang gaji yang didukung riset menunjukkan kamu tahu nilaimu dan memahami kondisi pasar, membuat posisimu lebih kuat.',
        'insightIncorrect':
            'Menyebutkan angka yang tidak realistis bisa membuat perusahaan ragu. Negosiasi yang baik didasari oleh data dan riset, bukan sekadar tebakan.',
      },
    ];
  }

  void _onOptionSelected(String optionId) {
    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionId == null) return;
    HapticFeedback.mediumImpact();

    final currentScene = _simulationScript[_currentStep];
    final selectedOption = (currentScene['options'] as List).firstWhere(
      (opt) => opt['id'] == _selectedOptionId,
    );
    final isCorrect = selectedOption['isCorrect'] as bool;

    if (!isCorrect) {
      setState(() {
        _lives--;
      });
    }

    _showInsightBottomSheet(
      isCorrect: isCorrect,
      insightText: isCorrect
          ? currentScene['insightCorrect']
          : currentScene['insightIncorrect'],
    );
  }

  void _goToNextStep() {
    Navigator.of(context).pop(); // Tutup bottom sheet
    if (_lives <= 0) {
      _showGameOverDialog();
      return;
    }

    if (_currentStep < _simulationScript.length - 1) {
      setState(() {
        _currentStep++;
        _selectedOptionId = null;
        _reasonController.clear();
      });
      _fadeController.reset();
      _fadeController.forward();
    } else {
      _showSuccessDialog();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScene = _simulationScript[_currentStep];
    final bool hasOptions = (currentScene['options'] as List).isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // --- APP BAR DENGAN PROGRES DAN NYAWA ---
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        title: StepProgressIndicator(
          totalSteps: _simulationScript.length,
          currentStep: _currentStep + 1,
          size: 8.h,
          padding: 4.w,
          selectedColor: AppTheme.primaryColor,
          unselectedColor: Colors.grey.shade300,
          roundedEdges: Radius.circular(10.r),
        ),
        actions: [
          Row(
            children: [
              ...List.generate(3, (index) {
                return AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: index < _lives ? 1.0 : 0.0,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.errorColor,
                    size: 24.sp,
                  ),
                );
              }),
              SizedBox(width: 20.w),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // --- AREA NARASI DAN KARAKTER ---
              _CharacterDialog(
                key: ValueKey(_currentStep), // Ganti key agar widget di-rebuild
                avatarPath: currentScene['avatar'],
                characterName: currentScene['character'],
                text: currentScene['scenario'],
              ),
              const Spacer(),

              // --- AREA INTERAKSI ---
              if (hasOptions) ...[
                _buildOptions(currentScene['options']),
                if (_selectedOptionId != null) _buildReasonInput(),
              ] else ...[
                // Tombol Lanjut untuk narasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep++;
                      });
                      _fadeController.reset();
                      _fadeController.forward();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text('Lanjut', style: AppTheme.button),
                  ),
                ),
              ],
              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---

  Widget _buildOptions(List<dynamic> options) {
    return Column(
      children: options.map((opt) {
        final bool isSelected = _selectedOptionId == opt['id'];
        return InkWell(
          onTap: () => _onOptionSelected(opt['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              opt['text'],
              style: AppTheme.body1.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonInput() {
    return Column(
      children: [
        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tuliskan alasanmu di sini...',
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text('Kirim Jawaban', style: AppTheme.button),
          ),
        ),
      ],
    );
  }

  // --- BOTTOM SHEET & DIALOG ---

  void _showInsightBottomSheet({
    required bool isCorrect,
    required String insightText,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(
              color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
              width: 4,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Insight Untukmu',
              style: AppTheme.h3.copyWith(
                color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              insightText,
              textAlign: TextAlign.center,
              style: AppTheme.body1,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lanjut'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        icon: Icon(
          Icons.heart_broken_rounded,
          color: AppTheme.errorColor,
          size: 48.sp,
        ),
        title: Text('Yah, Coba Lagi!', style: AppTheme.h3),
        content: Text(
          'Jangan menyerah, kegagalan adalah bagian dari belajar. Yuk, ulangi lagi simulasinya!',
          style: AppTheme.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentStep = 0;
                _lives = 3;
                _selectedOptionId = null;
                _reasonController.clear();
              });
            },
            child: const Text('Ulangi Simulasi'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28.sp),
            SizedBox(width: 8.w),
            Text('Selamat!', style: AppTheme.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kamu berhasil menyelesaikan simulasi wawancara kerja! Chapter 2 selesai.',
              style: AppTheme.body2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '🎉 Chapter 2 Complete!\n✨ +200 XP\n🔓 Chapter 3 Unlocked',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Mark chapter as complete
              ArticleProgress.completeChapter('chapter_2');

              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Return to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }
}

class _CharacterDialog extends StatelessWidget {
  final String avatarPath;
  final String characterName;
  final String text;

  const _CharacterDialog({
    super.key,
    required this.avatarPath,
    required this.characterName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(avatarPath, height: 100.h),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                characterName,
                style: AppTheme.subtitle1.copyWith(
                  color: AppTheme.primaryColorDark,
                ),
              ),
              const Divider(),
              Text(text, style: AppTheme.body1.copyWith(height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
