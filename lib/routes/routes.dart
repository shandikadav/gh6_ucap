import 'package:gh6_ucap/ui/pages/advanture_simulation_page.dart';
import 'package:gh6_ucap/ui/pages/login_page.dart';
import 'package:gh6_ucap/ui/pages/main_page.dart';
import 'package:gh6_ucap/ui/pages/onboarding_page.dart';
import 'package:gh6_ucap/ui/pages/register_page.dart';
import 'package:gh6_ucap/ui/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

part 'route_name.dart';

final routes = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: RouteName.splash,
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      path: '/register',
      name: RouteName.register,
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/login',
      name: RouteName.login,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: RouteName.onboarding,
      builder: (context, state) => OnboardingPage(),
    ),
    GoRoute(
      path: '/main',
      name: RouteName.main,
      builder: (context, state) => MainPage(),
    ),
    GoRoute(
      path: '/adventure/:scenarioTitle/:category',
      name: RouteName.adventure,
      builder: (context, state) {
        final scenarioTitle =
            state.pathParameters['scenarioTitle'] ?? 'Default Scenario';
        final category = state.pathParameters['category'] ?? 'General';

        return ScenarioScreen(
          scenarioTitle: Uri.decodeComponent(scenarioTitle),
          category: Uri.decodeComponent(category),
        );
      },
    ),
  ],
);
