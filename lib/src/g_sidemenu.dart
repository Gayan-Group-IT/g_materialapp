import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/s_sidemenu_theme.dart';

class GSideMenu extends StatefulWidget {
  final List items;
  final String? initialRoute;
  final Function(String route) onSelected;
  final Widget header;
  final GSideMenuThemeData? theme;
  final Stream<RouteSettings> routeStream;
  final String? path;

  const GSideMenu({
    super.key,
    this.items = const [],
    this.initialRoute,
    required this.onSelected,
    required this.header,
    this.theme,
    required this.routeStream,
    this.path
  });

  @override
  State<GSideMenu> createState() => GSideMenuState();
}

class GSideMenuState extends State<GSideMenu> {
  static double menuWidth = 240.0; //250
  final String kInitialRoute = '/';
  final kDefTheme = GSideMenuThemeData();

  List _items = [];
  late double _headerHeight;
  late String _initialRoute;
  late GSideMenuThemeData _theme;
  final ScrollController _menuItemsScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? kDefTheme;
    _initialRoute = kInitialRoute;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final colorScheme = Theme.of(context).colorScheme;

      _theme = GSideMenuThemeData(
        groupTitleColor: colorScheme.onPrimary,
        itemTitleColor: colorScheme.primaryFixedDim,
        activeItemTitleColor: colorScheme.onPrimary,
        itemIconColor: colorScheme.primaryFixedDim,
        activeItemIconColor: colorScheme.onPrimary,
        expandedIconColor: colorScheme.onPrimary,
        collapsedIconColor: colorScheme.primaryFixedDim,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: colorScheme.outline)),
          color: colorScheme.primary,
        ),
      );

      try {
        if(widget.path != null) {
          final data = await getSideMenu(widget.path!);
          _items = data.menuItems;
          _initialRoute = data.initialRoute ?? kInitialRoute;
        } else if(widget.items.isNotEmpty) {
          _items = widget.items;
        } else {
          _items = [];
        }

        if(context.mounted){
          setState(() {});
        }
      } catch (e) {
        debugPrint(e.toString());
      }

    });
  }

  @override
  void didUpdateWidget(covariant GSideMenu oldWidget) {
    if (widget.initialRoute != oldWidget.initialRoute) {
      _initialRoute = widget.initialRoute ?? kInitialRoute;
    }

    // if (widget.theme != oldWidget.theme && widget.theme != null) {
    //   _theme = widget.theme!;
    // }

    super.didUpdateWidget(oldWidget);
  }

  Future<MenuModel> getSideMenu(String path) async{
    try{
      final response = await rootBundle.loadString(path);
      final decodedResponse = jsonDecode(response);
      return MenuModel.fromJson(decodedResponse as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    _headerHeight = Theme.of(context).appBarTheme.toolbarHeight??kToolbarHeight;

    // add responsive
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: ScrollController(),
        child: Container(
          height: max(MediaQuery.of(context).size.height, _headerHeight),
          width: menuWidth,
          decoration: _theme.decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _headerHeight,
                child: widget.header,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(scrollbars: true),
                    child: StreamBuilder<RouteSettings>(
                      stream: widget.routeStream,
                      initialData: RouteSettings(name: _initialRoute),
                      builder: (context, snapshot) {
                        final String currentRoute = snapshot.data?.name??_initialRoute;

                        return ListView.builder(
                            itemCount: _items.length,
                            shrinkWrap: true,
                            controller: _menuItemsScrollController,
                            itemBuilder: (context, index) {
                              final dynamic item = _items[index];

                              switch (item.type) {
                                case "menu_group":
                                  return GroupBuilder(
                                    group: item,
                                    selectedRoute: currentRoute,
                                    margin: const EdgeInsets.only(
                                        left: 24.0,
                                        top: 12.0,
                                        right: 12.0,
                                        bottom: 12.0),
                                    onSelected: (value) => widget.onSelected(value),
                                    themeData: _theme,
                                  );
                                case "menu_item":
                                  return ItemButtonBuilder(
                                    item: item,
                                    selectedRoute: currentRoute,
                                    margin: const EdgeInsets.only(
                                        left: 24.0, right: 12.0),
                                    onSelected: (value) => widget.onSelected(value),
                                    themeData: _theme,
                                  );
                                default:
                                  return const SizedBox.shrink();
                              }
                            });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class GroupBuilder extends StatelessWidget {
  final MenuGroup group;
  final String selectedRoute;
  final EdgeInsetsGeometry? margin;
  final int level;
  final Function(String route)? onSelected;
  final GSideMenuThemeData themeData;

  const GroupBuilder({
    super.key,
    required this.group,
    required this.selectedRoute,
    this.margin,
    this.level = 0,
    this.onSelected,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(group.title ?? 'Group', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: themeData.groupTitleColor
          )),
          const SizedBox(height: 12.0),
          for (var child in group.items) _buildChild(child)
        ],
      ),
    );
  }

  Widget _buildChild(var child) {
    switch (child.type) {
      case "menu_group":
        return GroupBuilder(
          group: child,
          selectedRoute: selectedRoute,
          margin: const EdgeInsets.only(left: 12.0, top: 12.0),
          level: level + 1,
          onSelected: (value) =>
          (onSelected != null) ? onSelected!(value) : null,
          themeData: themeData,
        );
      case "menu_item":
        return ItemButtonBuilder(
          item: child,
          selectedRoute: selectedRoute,
          level: level,
          onSelected: (value) =>
          (onSelected != null) ? onSelected!(value) : null,
          themeData: themeData,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class ItemButtonBuilder extends StatelessWidget {
  final MenuItem item;
  final String selectedRoute;
  final EdgeInsetsGeometry? margin;
  final int level;
  final Function(String route)? onSelected;
  final GSideMenuThemeData themeData;

  const ItemButtonBuilder(
      {super.key,
        required this.item,
        required this.selectedRoute,
        this.margin,
        this.level = 0,
        this.onSelected,
        required this.themeData,
      });

  @override
  Widget build(BuildContext context) {
    bool selected = _isMenuItemSelected(selectedRoute, item);

    if (item.items.isEmpty) {
      return Container(
        margin: margin,
        child: Theme(
          data: Theme.of(context).copyWith(
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent),
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: _buildIcon(context, codePoint: item.iconCodePoint, selected: selected),
              title: _buildTitle(context, title: item.title, selected: selected),
              minLeadingWidth: 22,
              selected: selected,
              tileColor: Colors.transparent,
              dense: true,
              selectedTileColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              onTap: () {
                if (onSelected != null && item.route != null) {
                  onSelected!(item.route!);
                }
              },
            ),
          ),
        ),
      );
    }

    final childrenTiles = item.items.map((child) {
      switch (child.type) {
        case "menu_group":
          return GroupBuilder(
            group: child,
            margin: const EdgeInsets.only(left: 12.0, top: 12.0),
            level: level + 1,
            selectedRoute: selectedRoute,
            onSelected: (value) =>
            (onSelected != null) ? onSelected!(value) : null,
            themeData: themeData,
          );
        case "menu_item":
          return ItemButtonBuilder(
            item: child,
            selectedRoute: selectedRoute,
            margin: const EdgeInsets.only(left: 12.0),
            level: level + 1,
            onSelected: (value) =>
            (onSelected != null) ? onSelected!(value) : null,
            themeData: themeData,
          );
        default:
          return const SizedBox.shrink();
      }
    }).toList();

    return Container(
      margin: margin,
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            listTileTheme: const ListTileThemeData(
              minLeadingWidth: 22,
            )),
        child: Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            key: Key(selectedRoute),
            tilePadding: const EdgeInsets.all(0),
            leading: _buildIcon(context,
                codePoint: item.iconCodePoint, selected: selected),
            title: _buildTitle(context, title: item.title, selected: selected),
            initiallyExpanded: selected,
            iconColor: themeData.expandedIconColor,
            collapsedIconColor: themeData.collapsedIconColor,
            collapsedTextColor: Colors.transparent,
            // controller: controller,
            children: childrenTiles,
          ),
        ),
      ),
    );
  }

  bool _isMenuItemSelected(String route, MenuItem menuItem) {
    if (menuItem.items.isEmpty) {
      return route == menuItem.route;
    } else {
      bool selected = false;
      for (var child in menuItem.items) {
        selected = _mapSelectedRouteAsType(child.type, route, child);
        if (selected) {
          break;
        } else {
          continue;
        }
      }
      return selected;
    }
  }

  bool _isMenuGroupSelected(String route, MenuGroup menuGroup) {
    if (menuGroup.items.isEmpty) {
      return false;
    } else {
      bool selected = false;
      for (var child in menuGroup.items) {
        selected = _mapSelectedRouteAsType(child.type, route, child);
        if (selected) {
          break;
        } else {
          continue;
        }
      }
      return selected;
    }
  }

  bool _mapSelectedRouteAsType(String type, String route, dynamic child) {
    switch (child.type) {
      case "menu_group":
        return _isMenuGroupSelected(route, child);
      case "menu_item":
        return _isMenuItemSelected(route, child);
      default:
        return false;
    }
  }

  Widget _buildIcon(
      BuildContext context, {
        int? codePoint,
        bool selected = false,
      }) {
    Icon icon;

    if (level == 0) {
      if (codePoint != null) {
        icon = Icon(IconData(codePoint, fontFamily: 'MaterialIcons'), // Icons.settings
            size: selected ? 20 : 20,
            color: selected ? themeData.activeItemIconColor : themeData.itemIconColor);
      } else {
        icon = selected
            ? Icon(Icons.menu_open, size: 20, color: themeData.activeItemIconColor)
            : Icon(Icons.menu, size: 20, color: themeData.itemIconColor);
      }
    } else {
      icon = selected
          ? Icon(Icons.radio_button_checked,
          size: 10, color: themeData.activeItemIconColor)
          : Icon(Icons.radio_button_off, size: 10, color: themeData.itemIconColor);
    }

    return icon;
  }

  Widget _buildTitle(
      BuildContext context, {
        String? title,
        bool selected = false,
      }) {
    if (level == 0) {
      return Text(
        title ?? '',
        style: selected
            ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: themeData.activeItemTitleColor)
            : Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: themeData.itemTitleColor),
      );
    } else {
      return Text(
        title ?? '',
        style: selected
            ? Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: themeData.activeItemTitleColor)
            : Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: themeData.itemTitleColor),
      );
    }
  }
}


/// model classes
class MenuModel {
  String? message;
  List menuItems = [];
  String? iconFontFamily;
  String? initialRoute;

  MenuModel({this.message, this.menuItems = const [], this.iconFontFamily, this.initialRoute});

  MenuModel.fromJson(Map<String, dynamic> json) {
    message = json["message"];
    menuItems = (json["menuItems"] != null) ? getItems(json["menuItems"]) : [];
    iconFontFamily = json["iconFontFamily"] ?? 'MaterialIcons';
    initialRoute = json["initialRoute"] ?? '/';
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "menuItems": setItems(menuItems),
    "iconFontFamily": iconFontFamily ?? 'MaterialIcons',
    "initialRoute": initialRoute ?? '/',
  };

  static List getItems(List list) {
    List tempItems = [];
    for (var e in list) {
      switch (e["type"]) {
        case "menu_group":
          tempItems.add(MenuGroup.fromJson(e));
          break;
        case "menu_item":
          tempItems.add(MenuItem.fromJson(e));
          break;
        default:
          break;
      }
    }
    return tempItems;
  }

  static List setItems(List list) {
    List tempItems = [];
    for (var e in list) {
      tempItems.add(e.toJson());
    }
    return tempItems;
  }

  static T mapAsType<T>(
      String type, {
        required T menuGroup,
        required T menuItem,
        required T def,
      }) {
    switch (type) {
      case "menu_group":
        return menuGroup;
      case "menu_item":
        return menuItem;
      default:
        return def;
    }
  }
}

class MenuGroup {
  String? type;
  String? title;
  List items = [];

  MenuGroup({
    this.type,
    this.title,
    this.items = const [],
  });

  MenuGroup.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    title = json["title"];
    items = (json["items"] != null) ? MenuModel.getItems(json["items"]) : [];
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "title": title,
    "items": MenuModel.setItems(items),
  };
}

class MenuItem {
  String? type;
  String? title;
  String? route;
  int? iconCodePoint;
  List items = [];

  MenuItem({
    this.type,
    this.title,
    this.route,
    this.iconCodePoint,
    this.items = const [],
  });

  MenuItem.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    title = json["title"];
    route = json["route"];
    iconCodePoint = json["iconCodePoint"];
    items = (json["items"] != null) ? MenuModel.getItems(json["items"]) : [];
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "title": title,
    "route": route,
    "iconCodePoint": iconCodePoint,
    "items": MenuModel.setItems(items),
  };
}

enum ItemType { menu_group, menu_item }

