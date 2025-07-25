import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';
import 'package:gh6_ucap/ui/pages/all_adventure_page.dart';
import 'package:go_router/go_router.dart';

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

class _ContinueAdventureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        children: [
          Image.asset('assets/avatar.png', height: 100.h),
          SizedBox(height: 14.h),
          Text(
            'Wawancara Kerja Pertamaku',
            textAlign: TextAlign.center,
            style: AppTheme.h3,
          ),
          SizedBox(height: 4.h),
          Text(
            'Chapter 2',
            style: AppTheme.body2.copyWith(color: AppTheme.primaryColorDark),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress Chapter', style: AppTheme.caption),
              Text(
                '60%',
                style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            color: AppTheme.primaryColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pushNamed(
                RouteName.adventure,
                pathParameters: {
                  'scenarioTitle': Uri.encodeComponent('Wawancara Kerja'),
                  'category': Uri.encodeComponent('Karier'),
                },
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Lanjutkan Petualangan', style: AppTheme.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
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
  final adventures = [
    {
      'title': 'Simulasi Negosiasi Gaji',
      'tag': 'Karier',
      'icon': Icons.trending_up_rounded,
      'color': AppTheme.accentColor,
      'isLocked': false,
      'scenarioTitle': 'Negosiasi Gaji',
      'category': 'Karier',
    },
    {
      'title': 'Studi Kasus Budgeting',
      'tag': 'Keuangan',
      'icon': Icons.request_quote_rounded,
      'color': AppTheme.successColor,
      'isLocked': false,
      'scenarioTitle': 'Budgeting Bulanan',
      'category': 'Keuangan',
    },
    {
      'title': 'Menghadapi Diskriminasi',
      'tag': 'Sosial',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFF44336),
      'isLocked': false,
      'scenarioTitle': 'Menghadapi Diskriminasi',
      'category': 'Sosial',
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
                scenarioTitle: adventure['scenarioTitle'] as String,
                category: adventure['category'] as String,
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _AdventureCaseCard extends StatelessWidget {
  final String title, tag, scenarioTitle, category;
  final IconData icon;
  final Color color;
  final bool isLocked;

  const _AdventureCaseCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.scenarioTitle,
    required this.category,
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
        onTap: isLocked
            ? null
            : () {
                HapticFeedback.lightImpact();
                context.pushNamed(
                  RouteName.adventure,
                  pathParameters: {
                    'scenarioTitle': Uri.encodeComponent(scenarioTitle),
                    'category': Uri.encodeComponent(category),
                  },
                );
              },
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
