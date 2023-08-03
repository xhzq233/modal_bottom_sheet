import 'package:flutter/cupertino.dart';

final fakeBackButtonDispatcher = FakeBackButtonDispatcher._();

class FakeBackButtonDispatcher with WidgetsBindingObserver {
  final Set<Future<bool> Function()> _listeners = {};

  FakeBackButtonDispatcher._() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// to activate [FakeBackButtonDispatcher]
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
