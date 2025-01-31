import 'package:flutter/material.dart';

import 'src/g_app.dart';
import 'src/g_route_observer.dart';
import 'src/g_sidemenu.dart';
import 'theme/s_sidemenu_theme.dart';

export 'theme/s_sidemenu_theme.dart';

typedef GBuilder = GArgs Function(BuildContext context);

GRouteObserver get gRoutes => GRouteObserver.instance;

class GMaterialApp extends MaterialApp {
  // static final GRouteObserver gRoutes = GRouteObserver.instance;
  final GBuilder gBuilder;

  GMaterialApp({
    super.key,
    super.scaffoldMessengerKey,
    super.onUnknownRoute,
    super.onNavigationNotification,
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    super.title = '',
    super.onGenerateTitle,
    super.color,
    super.theme,
    super.darkTheme,
    super.highContrastTheme,
    super.highContrastDarkTheme,
    super.themeMode = ThemeMode.system,
    super.themeAnimationDuration = kThemeAnimationDuration,
    super.themeAnimationCurve = Curves.linear,
    super.locale,
    super.localizationsDelegates,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.supportedLocales = const <Locale>[Locale('en', 'US')],
    super.debugShowMaterialGrid = false,
    super.showPerformanceOverlay = false,
    super.checkerboardRasterCacheImages = false,
    super.checkerboardOffscreenLayers = false,
    super.showSemanticsDebugger = false,
    super.debugShowCheckedModeBanner = true,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
    super.scrollBehavior,
    super.useInheritedMediaQuery = false,
    super.themeAnimationStyle,

    /// required
    required String super.initialRoute,
    required super.routes,
    required this.gBuilder

  }): super (
    navigatorKey: gRoutes.navigatorKey,
    navigatorObservers: [
      gRoutes,
      ...navigatorObservers
    ],
  );

  @override
  TransitionBuilder? get builder => (context, child){
    final gArgs = gBuilder.call(context);

    return GApp(
      sideMenu: GSideMenu(
        onSelected: (routeName) => gRoutes.navigatorKey.currentState?.pushNamed(routeName),
        routeStream: gRoutes.routeStream,
        initialRoute: initialRoute,
        header: gArgs.sideMenuHeader,
        path: gArgs.sideMenuBundle,
        theme: gArgs.sideMenuTheme,
      ),
      appBar: gArgs.appBar,
      body: child ?? const SizedBox(),
      footer: gArgs.footer,
    );
  };

}

class GArgs {
  final AppBar appBar;
  final Widget? footer;

  final Widget sideMenuHeader;
  final GSideMenuThemeData? sideMenuTheme;
  final String sideMenuBundle;

  const GArgs({
    required this.appBar,
    this.footer,

    this.sideMenuHeader = const SizedBox.shrink(),
    this.sideMenuTheme,
    required this.sideMenuBundle
  });
}