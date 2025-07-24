import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/ui/pages/community_page.dart';
import 'package:gh6_ucap/ui/pages/home_page.dart';
import 'package:gh6_ucap/ui/pages/pojok_info_page.dart';
import 'package:gh6_ucap/ui/pages/profile_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  List<PersistentTabConfig> _tabs(BuildContext context) => [
    PersistentTabConfig(
      screen: HomePage(),
      item: ItemConfig(
        icon: Icon(Icons.home),
        title: "Home",
        textStyle: AppTheme.body1.copyWith(fontSize: 14.sp),
        activeForegroundColor: AppTheme.primaryColor,
        inactiveForegroundColor: AppTheme.textPrimaryColor,
      ),
    ),
    PersistentTabConfig(
      screen: PojokInfoPage(),
      item: ItemConfig(
        icon: Icon(Icons.library_books_rounded),
        title: "Pojok Info",
        textStyle: AppTheme.body1.copyWith(fontSize: 14.sp),
        activeForegroundColor: AppTheme.primaryColor,
        inactiveForegroundColor: AppTheme.textPrimaryColor,
      ),
    ),
    PersistentTabConfig(
      screen: CommunityPage(),
      item: ItemConfig(
        icon: Icon(Icons.people),
        title: "Komunitas",
        textStyle: AppTheme.body1.copyWith(fontSize: 14.sp),
        activeForegroundColor: AppTheme.primaryColor,
        inactiveForegroundColor: AppTheme.textPrimaryColor,
      ),
    ),
    PersistentTabConfig(
      screen: ProfilePage(),
      item: ItemConfig(
        icon: Icon(Icons.person),
        title: "Profil",
        textStyle: AppTheme.body1.copyWith(fontSize: 14.sp),
        activeForegroundColor: AppTheme.primaryColor,
        inactiveForegroundColor: AppTheme.textPrimaryColor,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      navBarOverlap: NavBarOverlap.full(),

      backgroundColor: Colors.transparent,
      tabs: _tabs(context), // Kirim context ke _tabs jika diperlukan
      navBarBuilder: (navBarConfig) => Style8BottomNavBar(
        height: 80.r,
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
      ),
    );
  }
}
