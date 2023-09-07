// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoTheme;
import 'package:flutter/material.dart' show Colors, MaterialLocalizations;
import 'package:flutter/widgets.dart';

import '../../modal_bottom_sheet.dart';

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow = BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_kPreviousPageVisibleOffset]
/// is the height that will be displayed from previous route.
class _StackModalBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;

  const _StackModalBottomSheetContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;

    final backgroundColor = this.backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor;
    Widget bottomSheetContainer = Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration: BoxDecoration(color: backgroundColor, boxShadow: [shadow]),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: child,
          ),
        ),
      ),
    );

    return bottomSheetContainer;
  }
}

Future<T?> showStackModalBottomSheet<T>({
  required BuildContext context,
  WidgetBuilder? builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? previousRouteAnimationCurve,
  bool useRootNavigator = false,
  bool bounce = true,
  bool? isDismissible,
  bool enableDrag = true,
  Radius topRadius = _kDefaultTopRadius,
  Duration? duration,
  RouteSettings? settings,
  Color? transitionBackgroundColor,
  BoxShadow? shadow,
  double? closeProgressThreshold,
  bool insideNavigator = false,
  PageRoute? insidePageRoute,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(insidePageRoute != null || builder != null);
  final hasMaterialLocalizations = Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) != null;
  final barrierLabel = hasMaterialLocalizations ? MaterialLocalizations.of(context).modalBarrierDismissLabel : '';
  final result = await Navigator.of(context, rootNavigator: useRootNavigator).push(
    StackModalBottomSheetRoute<T>(
      builder: builder,
      insideNavigator: insideNavigator,
      insidePageRoute: insidePageRoute,
      containerBuilder: (context, _, child) => _StackModalBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
        topRadius: topRadius,
        shadow: shadow,
      ),
      secondAnimationController: secondAnimation,
      expanded: expand,
      closeProgressThreshold: closeProgressThreshold,
      barrierLabel: barrierLabel,
      elevation: elevation,
      bounce: bounce,
      shape: shape,
      clipBehavior: clipBehavior,
      isDismissible: isDismissible ?? expand == false ? true : false,
      modalBarrierColor: barrierColor ?? Colors.black12,
      enableDrag: enableDrag,
      topRadius: topRadius,
      animationCurve: animationCurve,
      previousRouteAnimationCurve: previousRouteAnimationCurve,
      duration: duration,
      settings: settings,
      transitionBackgroundColor: transitionBackgroundColor ?? Colors.black,
    ),
  );
  return result;
}

class StackModalBottomSheetRoute<T> extends ModalSheetRoute<T> {
  final Radius topRadius;

  final Curve? previousRouteAnimationCurve;

  final BoxShadow? boxShadow;

  // Background color behind all routes
  // Black by default
  final Color? transitionBackgroundColor;

  StackModalBottomSheetRoute({
    WidgetWithChildBuilder? containerBuilder,
    double? closeProgressThreshold,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    AnimationController? secondAnimationController,
    Curve? animationCurve,
    Color? modalBarrierColor,
    bool bounce = true,
    bool isDismissible = true,
    bool enableDrag = true,
    required bool expanded,
    Duration? duration,
    RouteSettings? settings,
    ScrollController? scrollController,
    this.boxShadow = _kDefaultBoxShadow,
    this.transitionBackgroundColor,
    this.topRadius = _kDefaultTopRadius,
    this.previousRouteAnimationCurve,
    super.insideNavigator,
    super.insidePageRoute,
    super.builder,
  }) : super(
          closeProgressThreshold: closeProgressThreshold,
          scrollController: scrollController,
          containerBuilder: containerBuilder,
          bounce: bounce,
          barrierLabel: barrierLabel,
          secondAnimationController: secondAnimationController,
          modalBarrierColor: modalBarrierColor,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
          expanded: expanded,
          settings: settings,
          animationCurve: animationCurve,
          duration: duration,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!secondaryAnimation.isDismissed) {
      // performance optimization
      return buildSecondaryTransition(context, secondaryAnimation, child);
    }
    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }

  static Widget buildSecondaryTransition(BuildContext context, Animation<double> secondaryAnimation, Widget child) {
    final paddingTop = MediaQuery.paddingOf(context).top;
    final distanceWithScale = (paddingTop + _kPreviousPageVisibleOffset) * 0.9;
    final offsetY = secondaryAnimation.value * (paddingTop - distanceWithScale);
    final scale = 1 - secondaryAnimation.value / 10;

    final transform = Matrix4.identity()
      ..translate(0.0, offsetY)
      ..scale(scale);

    return Transform(transform: transform, alignment: Alignment.topCenter, child: child);
  }

  @override
  Widget getPreviousRouteTransition(BuildContext context, Animation<double> secondAnimation, Widget child) {
    return _CupertinoModalTransition(
      secondaryAnimation: secondAnimation,
      body: child,
      animationCurve: previousRouteAnimationCurve,
      topRadius: topRadius,
    );
  }
}

class _CupertinoModalTransition extends StatelessWidget {
  final Animation<double> secondaryAnimation;
  final Radius topRadius;
  final CurvedAnimation curvedAnimation;

  static const _cupertinoMaskColor = CupertinoColors.systemGrey3;

  final Widget body;

  _CupertinoModalTransition({
    Key? key,
    required this.secondaryAnimation,
    required this.body,
    required this.topRadius,
    Curve? animationCurve,
  })  : curvedAnimation = CurvedAnimation(parent: secondaryAnimation, curve: animationCurve ?? Curves.easeOut),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double startRoundCorner = 0.0;
    final paddingTop = MediaQuery.paddingOf(context).top;
    // if (Theme.of(context).platform == TargetPlatform.iOS && paddingTop > 20) {
    if (Platform.isIOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      //https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final maskColor = _cupertinoMaskColor.resolveFrom(context);

    final progress = curvedAnimation.value;
    final yOffset = progress * paddingTop;
    final scale = 1 - progress / 10;
    final radius = progress == 0 ? 0.0 : (1 - progress) * startRoundCorner + progress * topRadius.x;
    final trans = Matrix4.identity()
      ..translate(0.0, yOffset)
      ..scale(scale);

    return Transform(
      transform: trans,
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            body,
            // mask
            Positioned.fill(
              child: ColoredBox(color: maskColor.withOpacity(progress * 0.33)),
            ),
          ],
        ),
      ),
    );
  }
}
