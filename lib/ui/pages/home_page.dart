import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/services/scenario_service.dart';
import 'package:gh6_ucap/services/user_preferences.dart';
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
  String username = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserPreferences.getUserData();
      if (userData != null) {
        setState(() {
          username = userData['fullname'] ?? 'User';
        });
      } else {
        // Fallback: ambil dari UserPreferences method langsung
        final userName = await UserPreferences.getUserName();
        setState(() {
          username = userName.isNotEmpty ? userName : 'User';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        username = 'User';
      });
    }
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
                username,
                style: AppTheme.h3.copyWith(
                  color: AppTheme.textLightColor,
                  fontSize: 20.sp,
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

class _OtherAdventuresSection extends StatefulWidget {
  @override
  _OtherAdventuresSectionState createState() => _OtherAdventuresSectionState();
}

class _OtherAdventuresSectionState extends State<_OtherAdventuresSection> {
  final ScenarioService _scenarioService = ScenarioService();
  List<ScenarioWithStatus> scenarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final scenarioList = await _scenarioService.getScenariosWithStatus();
      if (mounted) {
        setState(() {
          scenarios = scenarioList.take(3).toList(); // Show only first 3
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading scenarios: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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

        // Loading atau Content
        isLoading
            ? SizedBox(
                height: 170.h,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : SizedBox(
                height: 170.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: scenarios.length,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemBuilder: (context, index) {
                    final scenarioWithStatus = scenarios[index];
                    return _DynamicAdventureCaseCard(
                      scenarioWithStatus: scenarioWithStatus,
                    );
                  },
                ),
              ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _DynamicAdventureCaseCard extends StatelessWidget {
  final ScenarioWithStatus scenarioWithStatus;

  const _DynamicAdventureCaseCard({required this.scenarioWithStatus});

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'record_voice_over': Icons.record_voice_over_rounded,
      'trending_up': Icons.trending_up_rounded,
      'account_balance_wallet': Icons.account_balance_wallet_rounded,
      'groups': Icons.groups_rounded,
      'home': Icons.home_rounded,
      'credit_card_off': Icons.credit_card_off_rounded,
      'swap_horiz': Icons.swap_horiz_rounded,
      'work': Icons.work_rounded,
    };
    return iconMap[iconName] ?? Icons.help_outline_rounded;
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = scenarioWithStatus.scenario;
    final isLocked = !scenarioWithStatus.isUnlocked;
    final color = _getColorFromHex(scenario.colorHex);

    return Container(
      width: 160.w,
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
            ? () => _showLockDialog(context)
            : () {
                HapticFeedback.lightImpact();
                context.pushNamed(
                  RouteName.adventure,
                  pathParameters: {
                    'scenarioTitle': Uri.encodeComponent(scenario.title),
                    'category': Uri.encodeComponent(scenario.category),
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
                  // Icon dengan requirement badge
                  Stack(
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
                        child: Icon(
                          _getIconFromName(scenario.iconName),
                          size: 24.sp,
                          color: Colors.white,
                        ),
                      ),
                      if (isLocked)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              'L${scenario.requiredLevel}',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title,
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
                      Row(
                        children: [
                          Text(
                            scenario.tag,
                            style: AppTheme.caption.copyWith(
                              color: isLocked ? Colors.grey.shade700 : color,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '• ${scenario.estimatedTime}m',
                            style: AppTheme.caption.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                      if (isLocked) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Butuh ${scenarioWithStatus.expNeeded} EXP lagi',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  void _showLockDialog(BuildContext context) {
    final scenario = scenarioWithStatus.scenario;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 24.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Scenario Terkunci',
                style: TextStyle(fontSize: 18.sp, color: Colors.orange),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 ${scenario.title}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Requirement untuk membuka:',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  'Level ${scenario.requiredLevel}',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  '${scenario.requiredExp} EXP',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progres saat ini:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Level: ${scenarioWithStatus.userLevel}/${scenario.requiredLevel}',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  Text(
                    'EXP: ${scenarioWithStatus.userExp}/${scenario.requiredExp}',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  if (scenarioWithStatus.expNeeded > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Butuh ${scenarioWithStatus.expNeeded} EXP lagi!',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mengerti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to scenarios that can give EXP
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Main Skenario Lain'),
          ),
        ],
      ),
    );
  }
}
