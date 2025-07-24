import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gh6_ucap/routes/routes.dart';
import 'package:gh6_ucap/themes/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () => routes.goNamed(RouteName.onboarding));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.primaryColor);
  }
}
