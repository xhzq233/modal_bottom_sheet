import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';

import '../modal_bottom_sheet.dart';
import 'bottom_sheet_route.dart';

class MaterialWithModalsPageRoute<T> extends PageRoute<T>
    with ModalPageRouteMixin<T> {
  MaterialWithModalsPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.maintainState = true,
  });

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Widget buildContent(BuildContext context) => builder(context);
}

class CupertinoWithModalsPageRoute<T> extends PageRoute<T>
    with ModalPageRouteMixin<T> {
  CupertinoWithModalsPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.maintainState = true,
  });

  @override
  final bool maintainState;

  final WidgetBuilder builder;

  @override
  PageTransitionsBuilder? get transitionsBuilderOverride =>
      CupertinoPageTransitionsBuilder();

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (secondaryAnimation.status != AnimationStatus.dismissed) {
      setNavigationBarBrightness(context, secondaryAnimation);
    }

    return super
        .buildTransitions(context, animation, secondaryAnimation, child);
  }

  void setNavigationBarBrightness(BuildContext context, Animation progress) {
    final currentBrightness = Theme.of(context).brightness;
    final isDarkMode = currentBrightness == Brightness.dark;
    // if value is around 0.33+-0.03, do not change
    if (progress.value > 0.3 && progress.value < 0.36) {
      return;
    }

    final useDark = progress.value < 0.33 ? !isDarkMode : isDarkMode;

    final overlayStyle =
        useDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }
}

mixin ModalPageRouteMixin<T> on PageRoute<T> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  ModalSheetRoute? _nextModalRoute;

  PageTransitionsBuilder? transitionsBuilderOverride;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is MaterialWithModalsPageRoute &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is ModalSheetRoute);
  }

  @override
  void didChangeNext(Route? nextRoute) {
    if (nextRoute is ModalSheetRoute) {
      _nextModalRoute = nextRoute;
    }

    super.didChangeNext(nextRoute);
  }

  @override
  bool didPop(T? result) {
    _nextModalRoute = null;
    return super.didPop(result);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsBuilder transitionsBuilder;
    if (transitionsBuilderOverride != null) {
      transitionsBuilder = transitionsBuilderOverride!;
    } else {
      final theme = Theme.of(context);
      transitionsBuilder =
          theme.pageTransitionsTheme.builders[theme.platform] ??
              ZoomPageTransitionsBuilder();
    }
    final nextRoute = _nextModalRoute;
    if (nextRoute != null) {
      if (!secondaryAnimation.isDismissed) {
        // Avoid default transition theme to animate when a new modal view is pushed

        return nextRoute.getPreviousRouteTransition(
            context, secondaryAnimation, child);
      } else {
        _nextModalRoute = null;
      }
    }

    return transitionsBuilder.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);
}
