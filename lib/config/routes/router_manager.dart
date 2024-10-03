import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/config/routes/navigator_observer.dart';

class RouterManager {
  static final config = GoRouter(
      observers: [
        CustomNavigatorObserver(),
      ],
      initialLocation: '',
      routes: [
        GoRoute(
          path: '',
          builder: (context, state) => Scaffold(),
        ),
      ]);
}
