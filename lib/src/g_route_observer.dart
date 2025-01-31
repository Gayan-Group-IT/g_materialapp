import 'dart:async';
import 'package:flutter/material.dart';

class GRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final GRouteObserver instance = GRouteObserver._internal();

  GRouteObserver._internal();

  factory GRouteObserver() {
    return instance;
  }

  /// navigator key
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Expose a stream to listen for route changes
  final StreamController<RouteSettings> _controller = StreamController<RouteSettings>.broadcast();
  Stream<RouteSettings> get routeStream => _controller.stream;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _controller.add(route.settings);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _controller.add(previousRoute.settings);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _controller.add(newRoute.settings);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute is PageRoute) {
      _controller.add(previousRoute.settings);
    }
  }

  /// Close stream to prevent memory leaks
  void dispose() {
    _controller.close();
  }
}
