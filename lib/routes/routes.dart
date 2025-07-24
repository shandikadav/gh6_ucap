import 'package:gh6_ucap/ui/pages/login_page.dart';
import 'package:gh6_ucap/ui/pages/register_page.dart';
import 'package:gh6_ucap/ui/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

part 'route_name.dart';

final routes = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: RouteName.login,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: RouteName.register,
      builder: (context, state) => RegisterPage(),
    ),
  ],
);
