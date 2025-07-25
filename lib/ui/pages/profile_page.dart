import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../services/profile_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(profileService: ProfileService())..add(LoadProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Default values (will be updated by BLoC)
  bool quest1Completed = false;
  bool quest2Completed = false;
  bool quest3Completed = false;
  int currentXP = 0;
  int nextLevelXP = 250;
  int currentLevel = 1;
  int totalScenarios = 0;
  int totalArticles = 0;
  int forumPosts = 0;
  int streakDays = 1;
  String userName = 'User';
  Map<String, dynamic> achievements = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
  }

  void _startAnimations() {
    _progressController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _updateDataFromUserData(Map<String, dynamic> userData) {
    setState(() {
      userName = userData['fullname'] ?? 'User';
      currentXP = userData['currentLevelExp'] ?? 0;
      nextLevelXP = userData['nextLevelExp'] ?? 1000;
      currentLevel = userData['level'] ?? 1;
      totalScenarios = userData['totalScenarios'] ?? 0;
      totalArticles = userData['totalArticles'] ?? 0;
      forumPosts = userData['forumPosts'] ?? 0;
      streakDays = userData['streakDays'] ?? 1;
      achievements = userData['achievements'] ?? {};

      final dailyQuests =
          userData['dailyQuests'] as Map<String, dynamic>? ?? {};
      quest1Completed = dailyQuests['quest1Completed'] ?? false;
      quest2Completed = dailyQuests['quest2Completed'] ?? false;
      quest3Completed = dailyQuests['quest3Completed'] ?? false;
    });
    _updateProgressAnimation();
  }

  void _completeQuest(int questIndex, int xpGained) {
    context.read<ProfileBloc>().add(
      CompleteQuest(questIndex: questIndex, expGained: xpGained),
    );
  }

  void _updateProgressAnimation() {
    final targetValue = nextLevelXP > 0 ? currentXP / nextLevelXP : 0.0;
    _progressAnimation =
        Tween<double>(
          begin: _progressAnimation.value,
          end: targetValue,
        ).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeInOutCubic,
          ),
        );
    _progressController.reset();
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _updateDataFromUserData(state.userData);
        } else if (state is ProfileQuestCompleted) {
          _updateDataFromUserData(state.userData);
          HapticFeedback.heavyImpact();
          _confettiController.play();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quest completed! +${state.expGained} XP'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        } else if (state is ProfileSignedOut) {
          // Navigate to login page or handle sign out
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EE),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              );
            }

            return Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF8F5EE),
                        Color(0xFFFFE4B5),
                        Color(0xFFF8F5EE),
                      ],
                      stops: [0.0, 0.3, 1.0],
                    ),
                  ),
                ),

                // Main content
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>().add(RefreshProfile());
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [_buildFlexibleHeader(), _buildMainContent()],
                  ),
                ),

                // Confetti effect
                _buildConfettiEffect(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlexibleHeader() {
    return SliverAppBar(
      expandedHeight: 300.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: SlideTransition(
          position: _slideAnimation,
          child: _buildProfileHeaderContent(),
        ),
        title: AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) => Opacity(
            opacity: _slideController.value,
            // child: Text(
            //   'Profil Kamu',
            //   style: TextStyle(
            //     color: Colors.black87,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 18.sp,
            //   ),
            // ),
          ),
        ),
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16.h),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Colors.black54,
            size: 24.w,
          ),
          onPressed: () => _showNotifications(),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black54, size: 24.w),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                _showSettings();
                break;
              case 'logout':
                _showLogoutDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20.w),
                  SizedBox(width: 12.w),
                  const Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, size: 20.w),
                  SizedBox(width: 12.w),
                  const Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileHeaderContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.8),
            const Color(0xFFFFA500).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Stack(
        children: [
          // Floating particles effect
          ...List.generate(5, (index) => _buildFloatingParticle(index)),

          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: _buildProfileAvatar(),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildUserInfo(),
                SizedBox(height: 20.h),
                _buildXpBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final offset = sin(_pulseController.value * 2 * pi + index) * 10;
        return Positioned(
          left: 50.0 * index + offset,
          top: 80.0 + offset,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 8.w,
              height: 8.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F0F0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 32.r,
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.person_rounded,
            size: 40.w,
            color: const Color(0xFFC7A500),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 16.w, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          userName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            'Level $currentLevel: ${_getLevelTitle(currentLevel)} 🏆',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 10) return 'Master Mandiri';
    if (level >= 7) return 'Pejuang Tangguh';
    if (level >= 5) return 'Pejuang Mandiri';
    if (level >= 3) return 'Pemula Bijak';
    return 'Pendatang Baru';
  }

  Widget _buildXpBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Progress ke Level ${currentLevel + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '$currentXP / $nextLevelXP XP',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildDailyQuestCard(),
                SizedBox(height: 24.h),
                _buildStatsGrid(),
                SizedBox(height: 24.h),
                _buildAchievementSection(),
                SizedBox(height: 24.h),
                _buildActionButtons(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: const Color(0xFFC7A500),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Misi Harian',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Selesaikan untuk mendapat XP!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildQuestItem(
            'Baca 1 artikel di Pojok Info',
            '20',
            quest1Completed,
            Icons.article_outlined,
            () => _completeQuest(1, 20),
          ),
          SizedBox(height: 12.h),
          _buildQuestItem(
            'Bergabung dengan 1 diskusi forum',
            '25',
            quest2Completed,
            Icons.forum_outlined,
            () => _completeQuest(2, 25),
          ),
          SizedBox(height: 12.h),
          _buildQuestItem(
            'Selesaikan 1 skenario simulasi',
            '15',
            quest3Completed,
            Icons.play_circle_outline,
            () => _completeQuest(3, 15),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestItem(
    String title,
    String reward,
    bool isCompleted,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: isCompleted ? null : onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: Colors.white,
                size: 18.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey[600] : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '+$reward XP',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'label': 'Skenario\nSelesai',
        'value': totalScenarios.toString(),
        'icon': Icons.play_circle_filled_rounded,
        'color': const Color(0xFF2196F3),
      },
      {
        'label': 'Artikel\nDibaca',
        'value': totalArticles.toString(),
        'icon': Icons.library_books_rounded,
        'color': const Color(0xFFFF9800),
      },
      {
        'label': 'Forum\nAktif',
        'value': forumPosts.toString(),
        'icon': Icons.forum_rounded,
        'color': const Color(0xFF4CAF50),
      },
      {
        'label': 'Hari\nBerturut',
        'value': '$streakDays 🔥',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFF44336),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Kamu',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              stat['label'] as String,
              stat['value'] as String,
              stat['icon'] as IconData,
              stat['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24.w, color: color),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection() {
    final achievementsList = [
      {'key': 'jobHunter', 'title': 'Job Hunter', 'icon': Icons.work_rounded},
      {
        'key': 'budgetPro',
        'title': 'Budget Pro',
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'key': 'socialButterfly',
        'title': 'Social Butterfly',
        'icon': Icons.people_alt_rounded,
      },
      {
        'key': 'stressMaster',
        'title': 'Stress Master',
        'icon': Icons.psychology_alt_rounded,
      },
      {
        'key': 'articleMaster',
        'title': 'Article Master',
        'icon': Icons.library_books,
      },
      {
        'key': 'discussionKing',
        'title': 'Discussion King',
        'icon': Icons.forum,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Lencana Prestasi',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => _showAllAchievements(),
              child: Text('Lihat Semua', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 0.9,
          ),
          itemCount: achievementsList.length,
          itemBuilder: (context, index) {
            final achievement = achievementsList[index];
            final isUnlocked = achievements[achievement['key']] ?? false;
            return _buildAchievementBadge(
              achievement['title'] as String,
              achievement['icon'] as IconData,
              isUnlocked,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, bool isUnlocked) {
    return GestureDetector(
      onTap: () => _showAchievementDetail(title, isUnlocked),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFC7A500)],
                    )
                  : null,
              color: isUnlocked ? null : Colors.grey[200],
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFFFD700)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 32.w,
              color: isUnlocked ? Colors.white : Colors.grey[400],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showLeaderboard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 4,
                ),
                icon: Icon(Icons.leaderboard_rounded, size: 20.w),
                label: FittedBox(
                  child: Text(
                    'Papan Peringkat',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.share_rounded, size: 20.w),
            label: Text(
              'Bagikan Profil',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 80.h),
      ],
    );
  }

  Widget _buildConfettiEffect() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2,
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.1,
        colors: const [
          Color(0xFFFFD700),
          Color(0xFF2196F3),
          Color(0xFF4CAF50),
          Color(0xFFF44336),
          Color(0xFFFF9800),
        ],
      ),
    );
  }

  // Action methods
  void _showNotifications() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi akan segera hadir!'),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showSettings() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pengaturan akan segera hadir!'),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('Logout', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(SignOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showLeaderboard() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Papan peringkat akan segera hadir!'),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _shareProfile() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur berbagi profil akan segera hadir!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showAllAchievements() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detail pencapaian akan segera hadir!'),
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showAchievementDetail(String title, bool isUnlocked) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(title, style: TextStyle(fontSize: 18.sp)),
        content: Text(
          isUnlocked
              ? 'Selamat! Kamu telah membuka lencana ini.'
              : 'Lencana ini belum terbuka. Terus semangat!',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
