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
  ],
);
