import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';
import 'package:gh6_ucap/ui/pages/all_adventure_page.dart';
import 'package:gh6_ucap/ui/pages/pojok_info_page.dart';
import 'package:gh6_ucap/models/article_progress.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: 270.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _ContinueAdventureCard(),
                      SizedBox(height: 24.h),
                      _StoryCard(),
                      SizedBox(height: 24.h),
                      _OtherAdventuresSection(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String greeting = '';
  String greetingIcon = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) {
      greeting = 'Selamat Pagi!';
      greetingIcon = '☀️';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat Siang!';
      greetingIcon = '🌤️';
    } else if (hour >= 15 && hour < 19) {
      greeting = 'Selamat Sore!';
      greetingIcon = '🌆';
    } else {
      greeting = 'Selamat Malam!';
      greetingIcon = '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 60.h,
        left: 20.w,
        right: 20.w,
        bottom: 40.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$greetingIcon $greeting',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.textLightColor.withOpacity(0.9),
                ),
              ),
              Text(
                'Pona Wijaya',
                style: AppTheme.h1.copyWith(
                  color: AppTheme.textLightColor,
                  fontSize: 30.sp,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 32.r,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: CircleAvatar(
              radius: 29.r,
              backgroundImage: const AssetImage('assets/avatar.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ContinueAdventureCard extends StatefulWidget {
  @override
  State<_ContinueAdventureCard> createState() => _ContinueAdventureCardState();
}

class _ContinueAdventureCardState extends State<_ContinueAdventureCard> {
  @override
  Widget build(BuildContext context) {
    final currentChapter = ArticleProgress.getCurrentChapter();
    final requiredArticles =
        ArticleProgress.getRequiredArticlesForCurrentChapter();
    final readCount = ArticleProgress.getReadCount(requiredArticles);
    final totalRequired = requiredArticles.length;
    final allRequiredRead = ArticleProgress.areRequiredArticlesRead(
      requiredArticles,
    );
    final progressPercentage = totalRequired > 0
        ? readCount / totalRequired
        : 1.0;

    // Get chapter info
    String chapterTitle = '';
    String chapterSubtitle = '';
    int chapterProgress = 0;

    switch (currentChapter) {
      case 'chapter_1':
        chapterTitle = 'Memulai Perjalanan Karierku';
        chapterSubtitle = 'Chapter 1 - Selesai ✓';
        chapterProgress = 100;
        break;
      case 'chapter_2_preparation':
        chapterTitle = 'Wawancara Kerja Pertamaku';
        chapterSubtitle = 'Chapter 2 - Persiapan';
        chapterProgress = 0;
        break;
      case 'chapter_2':
        chapterTitle = 'Wawancara Kerja Pertamaku';
        chapterSubtitle = 'Chapter 2';
        chapterProgress = ArticleProgress.getChapterProgress('chapter_2');
        break;
      case 'chapter_3':
        chapterTitle = 'Membangun Karier Impian';
        chapterSubtitle = 'Chapter 3';
        chapterProgress = ArticleProgress.getChapterProgress('chapter_3');
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20).r,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/avatar.png', height: 100.h),
          SizedBox(height: 14.h),
          Text(chapterTitle, textAlign: TextAlign.center, style: AppTheme.h3),
          SizedBox(height: 4.h),
          Text(
            chapterSubtitle,
            style: AppTheme.body2.copyWith(color: AppTheme.primaryColorDark),
          ),
          SizedBox(height: 20.h),

          // Progress artikel wajib (tampil jika belum semua dibaca)
          if (!allRequiredRead && totalRequired > 0) ...[
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Baca artikel wajib di Pojok Info untuk melanjutkan',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress artikel wajib', style: AppTheme.caption),
                      Text(
                        '$readCount dari $totalRequired artikel',
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                    color: AppTheme.accentColor,
                    minHeight: 6.h,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Progress chapter normal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress Chapter', style: AppTheme.caption),
              Text(
                '$chapterProgress%',
                style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: chapterProgress / 100,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            color: AppTheme.primaryColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 20.h),

          ElevatedButton.icon(
            onPressed: () {
              if (allRequiredRead &&
                  currentChapter != 'chapter_2_preparation') {
                // Navigate to adventure
                if (currentChapter == 'chapter_2') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SalaryNegotiationPage(),
                    ),
                  ).then((_) {
                    // Refresh state when returning from adventure
                    setState(() {});
                  });
                }
              } else {
                _showRequiredArticlesDialog(context);
              }
            },
            icon: Icon(
              allRequiredRead && currentChapter != 'chapter_2_preparation'
                  ? Icons.play_arrow_rounded
                  : Icons.lock_outline,
            ),
            label: Text(
              allRequiredRead && currentChapter != 'chapter_2_preparation'
                  ? 'Lanjutkan Petualangan'
                  : 'Baca Artikel Wajib',
              style: AppTheme.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  allRequiredRead && currentChapter != 'chapter_2_preparation'
                  ? AppTheme.primaryColor
                  : AppTheme.accentColor,
              foregroundColor: AppTheme.textPrimaryColor,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16).r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequiredArticlesDialog(BuildContext context) {
    final requiredArticles =
        ArticleProgress.getRequiredArticlesForCurrentChapter();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Artikel Wajib', style: AppTheme.h3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sebelum memulai petualangan ini, kamu perlu membaca artikel berikut di Pojok Info:',
                style: AppTheme.body2,
              ),
              SizedBox(height: 12.h),
              ...requiredArticles.map((articleId) {
                String title = _getArticleTitle(articleId);
                bool isRead = ArticleProgress.isArticleRead(articleId);
                return _buildRequiredArticleItem(title, isRead);
              }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Nanti')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PojokInfoPage()),
              ).then((_) {
                // Refresh state when returning from pojok info
                setState(() {});
              });
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

  String _getArticleTitle(String articleId) {
    switch (articleId) {
      case 'waspada_penipuan':
        return 'Waspada Penipuan Lowongan Kerja';
      case 'budget_bulanan':
        return 'Cara Membuat Budget Bulanan yang Realistis';
      case 'cv_menarik':
        return 'Membuat CV yang Menarik';
      case 'networking_profesional':
        return 'Membangun Networking Profesional';
      default:
        return articleId;
    }
  }

  Widget _buildRequiredArticleItem(String title, bool isRead) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRead ? Icons.check_circle : Icons.circle_outlined,
            color: isRead ? AppTheme.successColor : Colors.grey,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: AppTheme.body2.copyWith(
                decoration: isRead ? TextDecoration.lineThrough : null,
                color: isRead ? Colors.grey : AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16).r,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icon-book.png', width: 24.w),
              SizedBox(width: 8.w),
              Text('Cerita Terakhir', style: AppTheme.subtitle2),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '"Kamu baru saja mengirim email lamaran kerja ke 5 perusahaan. Deg-degan menunggu balasan, tiba-tiba teleponmu berdering..."',
            style: AppTheme.body2.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherAdventuresSection extends StatelessWidget {
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
      'title': 'Studi Kasus Budgeting',
      'tag': 'Keuangan',
      'icon': Icons.request_quote_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'destination': null,
    },
    {
      'title': 'Menghadapi Diskriminasi',
      'tag': 'Sosial',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFF44336),
      'isLocked': true,
      'destination': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Petualangan Lainnya',
                style: AppTheme.h3.copyWith(fontSize: 18.sp),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllAdventuresPage(),
                    ),
                  );
                },
                child: Text(
                  'Lihat Semua',
                  style: AppTheme.button.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 170.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: adventures.length,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemBuilder: (context, index) {
              final adventure = adventures[index];
              return _AdventureCaseCard(
                title: adventure['title'] as String,
                tag: adventure['tag'] as String,
                icon: adventure['icon'] as IconData,
                color: adventure['color'] as Color,
                isLocked: adventure['isLocked'] as bool,
                destination: adventure['destination'] as Widget?,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdventureCaseCard extends StatelessWidget {
  final String title, tag;
  final IconData icon;
  final Color color;
  final bool isLocked;
  final Widget? destination;

  const _AdventureCaseCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.isLocked,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade300 : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isLocked ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: isLocked || destination == null
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination!),
              ),
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLocked
                          ? null
                          : LinearGradient(
                              colors: [color.withOpacity(0.5), color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isLocked ? Colors.grey.shade400 : null,
                    ),
                    child: Icon(icon, size: 24.sp, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.subtitle2.copyWith(
                          fontSize: 13.sp,
                          color: isLocked
                              ? Colors.grey.shade600
                              : AppTheme.textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        tag,
                        style: AppTheme.caption.copyWith(
                          color: isLocked ? Colors.grey.shade700 : color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 40.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
