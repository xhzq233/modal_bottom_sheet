import 'package:flutter/cupertino.dart';

class ModalBackButtonDispatcher with WidgetsBindingObserver {
  final Set<Future<bool> Function()> _listeners = {};

  static final ModalBackButtonDispatcher instance =
      ModalBackButtonDispatcher._();

  ModalBackButtonDispatcher._() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// To activate [ModalBackButtonDispatcher].
  /// Must init before app start.
  void init() {}

  void addListener(Future<bool> Function() listener) {
    assert(!_listeners.contains(listener));
    _listeners.add(listener);
  }

  void removeListener(Future<bool> Function() listener) {
    assert(_listeners.contains(listener));
    _listeners.remove(listener);
  }

  @override
  Future<bool> didPopRoute() {
    if (_listeners.isEmpty) return super.didPopRoute();
    // last added listener is the first to be called
    final listener = _listeners.last;
    return listener.call();
  }
}
