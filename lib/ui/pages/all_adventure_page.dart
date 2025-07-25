import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/services/scenario_service.dart';
import 'package:gh6_ucap/models/scenario_model.dart';
import 'package:go_router/go_router.dart';

class AllAdventuresPage extends StatefulWidget {
  const AllAdventuresPage({super.key});

  @override
  _AllAdventuresPageState createState() => _AllAdventuresPageState();
}

class _AllAdventuresPageState extends State<AllAdventuresPage> {
  final ScenarioService _scenarioService = ScenarioService();
  List<ScenarioWithStatus> scenarios = [];
  bool isLoading = true;
  String selectedFilter = 'Semua';

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
          scenarios = scenarioList;
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

  List<ScenarioWithStatus> get filteredScenarios {
    if (selectedFilter == 'Semua') return scenarios;
    return scenarios
        .where((s) => s.scenario.category == selectedFilter)
        .toList();
  }

  List<String> get availableCategories {
    final categories = ['Semua'];
    categories.addAll(
      scenarios.map((s) => s.scenario.category).toSet().toList(),
    );
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Semua Petualangan', style: AppTheme.h3),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          if (true)
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: () async {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Seeding scenarios...')));
                await _scenarioService.seedScenarios();
                _loadScenarios();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Scenarios seeded successfully!')),
                );
              },
              tooltip: 'Seed Scenarios (Dev Only)',
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : Column(
              children: [
                // Filter tabs
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableCategories.length,
                    itemBuilder: (context, index) {
                      final category = availableCategories[index];
                      final isSelected = selectedFilter == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = category;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 12.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // Scenarios list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: filteredScenarios.length,
                    itemBuilder: (context, index) {
                      final scenarioWithStatus = filteredScenarios[index];
                      return _DynamicVerticalAdventureCard(
                        scenarioWithStatus: scenarioWithStatus,
                      );
                    },
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),
    );
  }
}

class _DynamicVerticalAdventureCard extends StatelessWidget {
  final ScenarioWithStatus scenarioWithStatus;

  const _DynamicVerticalAdventureCard({required this.scenarioWithStatus});

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

    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
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
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Icon with level badge
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: isLocked
                            ? null
                            : LinearGradient(
                                colors: [color.withOpacity(0.5), color],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isLocked ? Colors.grey.shade300 : null,
                      ),
                      child: Icon(
                        _getIconFromName(scenario.iconName),
                        size: 24.sp,
                        color: isLocked ? Colors.grey.shade600 : Colors.white,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.orange : Colors.green,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'L${scenario.requiredLevel}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                              scenario.title,
                              style: AppTheme.subtitle2.copyWith(
                                color: isLocked ? Colors.grey[600] : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              scenario.difficulty,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      Row(
                        children: [
                          Text(
                            scenario.tag,
                            style: AppTheme.caption.copyWith(color: color),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.access_time,
                            size: 12.w,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${scenario.estimatedTime} menit',
                            style: AppTheme.caption,
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.stars, size: 12.w, color: Colors.amber),
                          SizedBox(width: 2.w),
                          Text(
                            '+${scenario.rewardExp} EXP',
                            style: AppTheme.caption.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (isLocked) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12.w,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Butuh ${scenarioWithStatus.expNeeded} EXP lagi',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action icon
                Icon(
                  isLocked
                      ? Icons.lock_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 16.sp,
                ),
              ],
            ),
          ),
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
              scenario.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Learning Outcomes:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            ...scenario.learningOutcomes.map(
              (outcome) => Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 2.h),
                child: Text(
                  '• $outcome',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ),
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
                    'Requirements:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Level: ${scenario.requiredLevel} (Current: ${scenarioWithStatus.userLevel})',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  Text(
                    'EXP: ${scenario.requiredExp} (Current: ${scenarioWithStatus.userExp})',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  if (scenarioWithStatus.expNeeded > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Butuh ${scenarioWithStatus.expNeeded} EXP lagi!',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
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
              // Could navigate to available scenarios
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
