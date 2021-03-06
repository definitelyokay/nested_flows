import 'package:flutter/material.dart';

class PageWithoutAnimation<T> extends Page<T> {
  const PageWithoutAnimation({
    LocalKey? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => PageRouteBuilder<T>(
        settings: this,
        pageBuilder: (_, __, ___) => child,
        // don't wrap in an animation to create a page without animation.
      );
}
