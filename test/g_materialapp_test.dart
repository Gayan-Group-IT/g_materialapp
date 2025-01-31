import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:g_materialapp/g_materialapp.dart';

void main() {
  test('Runner', () {
    return const MyApp();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  buildScaffold(BuildContext context, String name) =>
      Scaffold(body: Center(child: Text(name)));


  @override
  Widget build(BuildContext context) {
    return GMaterialApp(
      title: 'GApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        Routes.intro: (context) => buildScaffold(context, 'Intro'),
        Routes.home: (context) => buildScaffold(context, 'Home'),
        Routes.dashboard: (context) => buildScaffold(context, 'Dashboard'),

        Routes.sub1: (context) => buildScaffold(context, 'Sub 1'),
        Routes.sub2: (context) => buildScaffold(context, 'Sub 2'),
        Routes.sub3: (context) => buildScaffold(context, 'Sub 3'),

        Routes.g1: (context) => buildScaffold(context, 'Group Item 1'),
        Routes.g2: (context) => buildScaffold(context, 'Group Item 2'),
        Routes.g3: (context) => buildScaffold(context, 'Group Item 3'),
      },
      initialRoute: Routes.intro,
      gBuilder: (context) => GArgs(
          sideMenuBundle: 'assets/menu_list.json',
          appBar: AppBar()
      ),
    );

  }
}

class Routes {
  static const String intro = "/intro";
  static const String home = "/home";
  static const String dashboard = "/dashboard";

  static const String sub1 = "/item/sub1";
  static const String sub2 = "/item/sub2";
  static const String sub3 = "/item/sub3";

  static const String g1 = "/group/item1";
  static const String g2 = "/group/item2";
  static const String g3 = "/group/item3";
}