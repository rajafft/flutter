import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';

class TopBorderNavBar extends StatelessWidget {
  TopBorderNavBar({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin = const EdgeInsets.symmetric(horizontal: 6),
    this.itemPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuint,
    this.dotIndicatorColor,
  }) : super(key: key);

  /// A list of tabs to display, ie `Home`, `Profile`,`Cart`, etc
  final List<TopBorderNavBarItem> items;

  /// The tab to display.
  final int currentIndex;

  /// Returns the index of the tab that was tapped.
  final Function(int)? onTap;

  /// The color of the icon and text when the item is selected.
  final Color? selectedItemColor;

  /// The color of the icon and text when the item is not selected.
  final Color? unselectedItemColor;

  /// A convenience field for the margin surrounding the entire widget.
  final EdgeInsets margin;

  /// The padding of each item.
  final EdgeInsets itemPadding;

  /// The transition duration
  final Duration duration;

  /// The transition curve
  final Curve curve;

  /// The color of the Dot indicator.
  final Color? dotIndicatorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // padding: EdgeInsets.symmetric(vertical: 6),
      color: AppTheme.navBarColor,
      child: Padding(
        padding: margin,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final item in items)
              TweenAnimationBuilder<double>(
                tween: Tween(
                  end: items.indexOf(item) == currentIndex ? 1.0 : 0.0,
                ),
                curve: curve,
                duration: duration,
                builder: (context, t, _) {
                  final _selectedColor = item.selectedColor ??
                      selectedItemColor ??
                      theme.primaryColor;

                  final _unselectedColor = item.unselectedColor ??
                      unselectedItemColor ??
                      theme.iconTheme.color;

                  return Material(
                    color:
                        Color.lerp(Colors.transparent, Colors.transparent, t),
                    child: InkWell(
                      onTap: () => onTap?.call(items.indexOf(item)),
                      focusColor: _selectedColor.withOpacity(0.1),
                      highlightColor: _selectedColor.withOpacity(0.1),
                      splashColor: _selectedColor.withOpacity(0.1),
                      hoverColor: _selectedColor.withOpacity(0.1),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding: itemPadding -
                              EdgeInsets.only(right: itemPadding.right * t),
                          child: Row(
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color: Color.lerp(
                                      _unselectedColor, _selectedColor, t),
                                  size: 30,
                                ),
                                child: item.icon,
                              ),
                            ],
                          ),
                        ),
                        ClipRect(
                          child: SizedBox(
                            height: 45,
                            child: Align(
                              alignment: Alignment.topCenter,
                              widthFactor: t,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: itemPadding.right / 0.89,
                                    right: itemPadding.right),
                                child: DefaultTextStyle(
                                    style: TextStyle(
                                      color: Color.lerp(
                                          _selectedColor.withOpacity(0.0),
                                          _selectedColor,
                                          t),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 40, right: 40),
                                      width: 25,
                                      height: 3,
                                      color: dotIndicatorColor != null
                                          ? dotIndicatorColor
                                          : _selectedColor,
                                    )

                                    /* CircleAvatar(
                                      radius: 2.5,
                                      backgroundColor: dotIndicatorColor != null
                                          ? dotIndicatorColor
                                          : _selectedColor),*/
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// A tab to display in a [TopBorderNavBar]
class TopBorderNavBarItem {
  /// An icon to display.
  final Widget icon;

  /// A primary color to use for this tab.
  final Color? selectedColor;

  /// The color to display when this tab is not selected.
  final Color? unselectedColor;

  TopBorderNavBarItem({
    required this.icon,
    this.selectedColor,
    this.unselectedColor,
  });
}
