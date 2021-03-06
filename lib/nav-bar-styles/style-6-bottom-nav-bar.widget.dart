part of persistent_bottom_nav_bar;

class BottomNavStyle6 extends StatefulWidget {
  final int selectedIndex;
  final int previousIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;
  final double navBarHeight;
  final NavBarPadding padding;
  final Function(int) popAllScreensForTheSelectedTab;
  final bool popScreensOnTapOfSelectedTab;
  final ItemAnimationProperties itemAnimationProperties;

  BottomNavStyle6({
    Key key,
    this.selectedIndex,
    this.previousIndex,
    this.showElevation = false,
    this.iconSize,
    this.backgroundColor,
    this.itemAnimationProperties,
    this.popScreensOnTapOfSelectedTab,
    this.navBarHeight = 0.0,
    @required this.items,
    this.onItemSelected,
    this.padding,
    this.popAllScreensForTheSelectedTab,
  });

  @override
  _BottomNavStyle6State createState() => _BottomNavStyle6State();
}

class _BottomNavStyle6State extends State<BottomNavStyle6>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllerList;
  List<Animation<double>> _animationList;

  int _lastSelectedIndex;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>();
    _animationList = List<Animation<double>>();

    for (int i = 0; i < widget.items.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration: widget.itemAnimationProperties?.duration ??
              Duration(milliseconds: 400),
          vsync: this));
      _animationList.add(Tween(begin: 0.95, end: 1.18)
          .chain(CurveTween(
              curve: widget.itemAnimationProperties?.curve ?? Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationControllerList[_selectedIndex].forward();
    });
  }

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected,
      double height, int itemIndex) {
    return widget.navBarHeight == 0
        ? SizedBox.shrink()
        : AnimatedBuilder(
            animation: _animationList[itemIndex],
            builder: (context, child) => Transform.scale(
              scale: _animationList[itemIndex].value,
              child: Container(
                width: 150.0,
                height: height,
                child: Container(
                  alignment: Alignment.center,
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: IconTheme(
                          data: IconThemeData(
                              size: widget.iconSize,
                              color: isSelected
                                  ? (item.activeContentColor == null
                                      ? item.activeColor
                                      : item.activeContentColor)
                                  : item.inactiveColor == null
                                      ? item.activeColor
                                      : item.inactiveColor),
                          child: item.icon,
                        ),
                      ),
                      item.title == null
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Material(
                                type: MaterialType.transparency,
                                child: FittedBox(
                                  child: Text(
                                    item.title,
                                    style: item.titleStyle != null
                                        ? (item.titleStyle.apply(
                                            color: isSelected
                                                ? (item.activeContentColor ==
                                                        null
                                                    ? item.activeColor
                                                    : item.activeContentColor)
                                                : item.inactiveColor))
                                        : TextStyle(
                                            color: isSelected
                                                ? (item.activeContentColor ==
                                                        null
                                                    ? item.activeColor
                                                    : item.activeContentColor)
                                                : item.inactiveColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: item.titleFontSize),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.items.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length != _animationControllerList.length) {
      _animationControllerList = List<AnimationController>();
      _animationList = List<Animation<double>>();

      for (int i = 0; i < widget.items.length; ++i) {
        _animationControllerList.add(AnimationController(
            duration: widget.itemAnimationProperties?.duration ??
                Duration(milliseconds: 400),
            vsync: this));
        _animationList.add(Tween(begin: 0.95, end: 1.18)
            .chain(CurveTween(
                curve: widget.itemAnimationProperties?.curve ?? Curves.ease))
            .animate(_animationControllerList[i]));
      }
    }
    if (widget.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.selectedIndex;
      _animationControllerList[_selectedIndex].forward();
      _animationControllerList[_lastSelectedIndex].reverse();
    }
    return Container(
      width: double.infinity,
      height: widget.navBarHeight,
      padding: EdgeInsets.only(
          left:
              widget.padding?.left ?? MediaQuery.of(context).size.width * 0.04,
          right:
              widget.padding?.right ?? MediaQuery.of(context).size.width * 0.04,
          top: widget.padding?.top ?? widget.navBarHeight * 0.15,
          bottom: widget.padding?.bottom ?? widget.navBarHeight * 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.items.map((item) {
          var index = widget.items.indexOf(item);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.items[index].onPressed != null) {
                  widget.items[index].onPressed();
                } else {
                  if (index != _selectedIndex) {
                    _lastSelectedIndex = _selectedIndex;
                    _selectedIndex = index;
                    _animationControllerList[_selectedIndex].forward();
                    _animationControllerList[_lastSelectedIndex].reverse();
                  } else if (widget.popScreensOnTapOfSelectedTab &&
                      widget.previousIndex == index) {
                    widget.popAllScreensForTheSelectedTab(index);
                  }
                  widget.onItemSelected(index);
                }
              },
              child: Container(
                color: Colors.transparent,
                child: _buildItem(item, widget.selectedIndex == index,
                    widget.navBarHeight, index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
