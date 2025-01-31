import 'package:flutter/material.dart';

import 'g_sidemenu.dart';

class GApp extends StatefulWidget {
  final GSideMenu sideMenu;
  final AppBar appBar;
  final Widget body;
  final Widget? footer;

  const GApp({super.key,
    required this.sideMenu,
    required this.appBar,
    required this.body,
    this.footer,
  });

  @override
  State<GApp> createState() => GAppState();
}

class GAppState extends State<GApp> with SingleTickerProviderStateMixin {
  static const mobileThreshold = 768.0;
  static double sideMenuWidth = GSideMenuState.menuWidth;

  late AnimationController _animationController;
  late Animation _animation;
  bool _isMobile = false;
  bool _isOpenSideMenu = false;
  double _screenWidth = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    if (_screenWidth == mediaQuery.size.width) {
      return;
    }

    setState(() {
      _isMobile = mediaQuery.size.width < mobileThreshold;
      _isOpenSideMenu = !_isMobile;
      _animationController.value = _isMobile ? 0 : 1;
      _screenWidth = mediaQuery.size.width;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSideMenu() {
    setState(() {
      _isOpenSideMenu = !_isOpenSideMenu;
      if (_isOpenSideMenu) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void openSideMenu(){
    setState(() {
      _isOpenSideMenu = true;
      _animationController.forward();
    });
  }

  void closeSideMenu(){
    setState(() {
      _isOpenSideMenu = false;
      _animationController.reverse();
    });
  }

  Widget _buildSideMenuButton() {
    final IconData menuIcon =
    _isOpenSideMenu ? Icons.menu_open_outlined : Icons.menu;

    return IconButton(
      onPressed: () => _toggleSideMenu(),
      icon: Icon(menuIcon),
      splashRadius: 24.0,
    );
  }

  AppBar get _appBar => AppBar(
    leading: _buildSideMenuButton(),
    title: widget.appBar.title,
    actions: widget.appBar.actions,
    flexibleSpace: widget.appBar.flexibleSpace,
    bottom: widget.appBar.bottom,
    elevation: widget.appBar.elevation,
    scrolledUnderElevation: widget.appBar.scrolledUnderElevation,
    notificationPredicate: widget.appBar.notificationPredicate,
    shadowColor: widget.appBar.shadowColor,
    surfaceTintColor: widget.appBar.surfaceTintColor,
    shape: widget.appBar.shape,
    backgroundColor: widget.appBar.backgroundColor,
    foregroundColor: widget.appBar.foregroundColor,
    iconTheme: widget.appBar.iconTheme,
    actionsIconTheme: widget.appBar.actionsIconTheme,
    primary: widget.appBar.primary,
    centerTitle: widget.appBar.centerTitle,
    excludeHeaderSemantics: widget.appBar.excludeHeaderSemantics,
    titleSpacing: widget.appBar.titleSpacing,
    toolbarOpacity: widget.appBar.toolbarOpacity,
    bottomOpacity: widget.appBar.bottomOpacity,
    toolbarHeight: widget.appBar.toolbarHeight,
    leadingWidth: widget.appBar.leadingWidth,
    toolbarTextStyle: widget.appBar.toolbarTextStyle,
    titleTextStyle: widget.appBar.titleTextStyle,
    systemOverlayStyle: widget.appBar.systemOverlayStyle,
    forceMaterialTransparency: widget.appBar.forceMaterialTransparency,
    clipBehavior: widget.appBar.clipBehavior,
  );

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;

    return SafeArea(
      child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final margin = _isMobile ? EdgeInsets.zero : EdgeInsets.only(left: sideMenuWidth * _animation.value);

            return Stack(
              children: [
                Scaffold(
                  appBar: PreferredSize(
                      preferredSize: _appBar.preferredSize, child: Container(
                      margin: margin,
                      child: _appBar
                  )),
                  body: Container(
                      margin: margin,
                      child: widget.body
                  ),
                  backgroundColor: surface,
                ),

                if (_animation.value > 0 && _isMobile)
                  Container(
                    color: surface.withAlpha(
                        (150 * _animation.value).toInt()),
                  ),

                if (_animation.value == 1 && _isMobile)
                  GestureDetector(
                    onTap: () => _toggleSideMenu(),
                  ),

                ClipRect(
                  child: SizedOverflowBox(
                    size: Size(
                        sideMenuWidth *
                            _animation.value,
                        double.infinity),
                    child: widget.sideMenu,
                  ),
                ),
              ],
            );
          }),
    );
  }

}
