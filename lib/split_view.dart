library split_view;

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A SplitView class.
class SplitView extends StatefulWidget {
  static const Color defaultGripColor = Colors.grey;
  static const Color defaultGripColorActive =
      Color.fromARGB(0xff, 0x66, 0x66, 0x66);
  static const double defaultGripSize = 12.0;
  static const double defaultInitialWeight = 0.5;
  static const double defaultPositionLimit = 20.0;

  final List<Widget> children;

  final SplitViewController? controller;

  /// The [viewMode] specifies how to arrange views.
  final SplitViewMode viewMode;

  /// The grip size.
  final double gripSize;

  /// Specifies the minimum movement range of the grip.
  ///
  /// If [viewMode] is Vertical, this property will be ignored.
  final double? minWidthSidebar;

  /// Specifies the maximum movement range of the grip.
  ///
  /// If [viewMode] is Vertical, this property will be ignored.
  final double? maxWidthSidebar;

  /// Specifies the minimum movement range of the grip.
  ///
  /// If [viewMode] is Vertical, this property will be ignored.
  final double? minHeightSidebar;

  /// Specifies the maximum movement range of the grip.
  ///
  /// If [viewMode] is Vertical, this property will be ignored.
  final double? maxHeightSidebar;

  /// Initial value of division ratio.
  final double initialWeight;

  /// Grip color.
  final Color gripColor;

  /// Active grip color.
  final Color gripColorActive;

  /// Up / down or left / right movement prohibited range.
  ///
  /// Same as minWidthSidebar/maxWidthSidebar or minHeightSidebar/maxHeightSidebar,
  /// but cannot be specified individually.
  final double positionLimit;

  /// Called when the user moves the grip.
  final ValueChanged<double?>? onWeightChanged;

  /// Creates a [SplitView].
  SplitView({
    Key? key,
    required this.children,
    required this.viewMode,
    this.gripSize = defaultGripSize,
    this.controller,
    this.minWidthSidebar,
    this.maxWidthSidebar,
    this.minHeightSidebar,
    this.maxHeightSidebar,
    this.initialWeight = defaultInitialWeight,
    this.gripColor = defaultGripColor,
    this.gripColorActive = defaultGripColorActive,
    this.positionLimit = defaultPositionLimit,
    this.onWeightChanged,
  }) : super(key: key);

  @override
  State createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late SplitViewController _controller;
  double? defaultWeight;
  late ValueNotifier<double?> weight;
  double? _prevWeight;
  late Color _gripColor;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller != null ? widget.controller! : SplitViewController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.defaultWeight =
        PageStorage.of(context)?.readState(context, identifier: widget.key) ??
            widget.initialWeight;
    weight = ValueNotifier(defaultWeight);
    _gripColor = widget.gripColor;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.viewMode == SplitViewMode.Vertical) {
          return _buildVerticalView(context, constraints, _controller.weights);
        } else {
          return _buildHorizontalView(
              context, constraints, _controller.weights);
        }
        // return ValueListenableBuilder<double?>(
        //   valueListenable: weight,
        //   builder: (_, w, __) {
        //     if (widget.onWeightChanged != null && _prevWeight != w) {
        //       _prevWeight = w;
        //       PageStorage.of(context)?.writeState(context, w, identifier: widget.key);
        //       widget.onWeightChanged!(w);
        //     }
        //     if (widget.viewMode == SplitViewMode.Vertical) {
        //       return _buildVerticalView(context, constraints, w!);
        //     } else {
        //       return _buildHorizontalView(context, constraints, w!);
        //     }
        //   },
        // );
      },
    );
  }

  Stack _buildVerticalView(
      BuildContext context, BoxConstraints constraints, List<double?> weights) {
    double viewsHeight = constraints.maxHeight -
        (widget.gripSize * (widget.children.length - 1));
    double top = 0;

    //TODO: 移動制限の処理は後で
    /*
    if (widget.maxHeightSidebar != null && top > widget.maxHeightSidebar!) {
      top = widget.maxHeightSidebar!;
      bottom = constraints.maxHeight - widget.maxHeightSidebar!;
    } else if (widget.minHeightSidebar != null &&
        top < widget.minHeightSidebar!) {
      top = widget.minHeightSidebar!;
      bottom = constraints.maxHeight - widget.minHeightSidebar!;
    }
     */

    //TODO: viewごとでweightが変わるので計算する処理がいる
    double weight = 1.0 / widget.children.length;

    var children = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      var child = widget.children[i];
      children.add(Positioned(
        top: top,
        height: viewsHeight * weight,
        left: 0,
        right: 0,
        child: child,
      ));
      top += (viewsHeight * weight);
      if (i != widget.children.length - 1) {
        children.add(Positioned(
          top: top,
          height: widget.gripSize,
          left: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            onEnter: (event) {
              setState(() {
                _gripColor = widget.gripColorActive;
              });
            },
            onExit: (_) {
              if (_dragging == false)
                setState(() => _gripColor = widget.gripColor);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragDown: (details) {
                _dragging = true;
                _gripColor = widget.gripColorActive;
              },
              onVerticalDragEnd: (details) {
                _dragging = false;
                setState(() => _gripColor = widget.gripColor);
              },
              onVerticalDragUpdate: (detail) {
                final RenderBox container =
                    context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dy > widget.positionLimit &&
                    pos.dy < (container.size.height - widget.positionLimit)) {
                  var weight1 = pos.dy / viewsHeight;
                  var weight2 =
                      (weights[i] ?? 0) + (weights[i + 1] ?? 0) - weight1;
                  setState(() {
                    _controller._weights[i] = weight1;
                    _controller.weights[i + 1] = weight2;
                  });
                  //TODO: 変更があったことを通知する必要がある
                  // weight.value = pos.dy / container.size.height;
                }
              },
              child: Container(color: widget.gripColor),
            ),
          ),
        ));
        top += widget.gripSize;
      }
    }

    return Stack(
      children: children,
    );
  }

  Widget _buildHorizontalView(
      BuildContext context, BoxConstraints constraints, List<double?> weights) {
    double viewsWidth =
        constraints.maxWidth - (widget.gripSize * (widget.children.length - 1));
    double left = 0;

    //TODO: 移動制限の処理は後で
    /*
    if (widget.maxWidthSidebar != null && left > widget.maxWidthSidebar!) {
      left = widget.maxWidthSidebar!;
      right = constraints.maxWidth - widget.maxWidthSidebar!;
    } else if (widget.minWidthSidebar != null &&
        left < widget.minWidthSidebar!) {
      left = widget.minWidthSidebar!;
      right = constraints.maxWidth - widget.minWidthSidebar!;
    }
     */

    //TODO: viewごとでweightが変わるので計算する処理がいる
    double weight = 1.0 / widget.children.length;

    var children = <Widget>[];
    widget.children.forEach((child) {
      if (widget.children.first != child) {
        children.add(Positioned(
          left: left,
          width: widget.gripSize,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (event) {
              setState(() {
                _gripColor = widget.gripColorActive;
              });
            },
            onExit: (_) {
              if (_dragging == false)
                setState(() => _gripColor = widget.gripColor);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragDown: (details) =>
                  _gripColor = widget.gripColorActive,
              onHorizontalDragEnd: (details) {
                _dragging = false;
                setState(() => _gripColor = widget.gripColor);
              },
              onHorizontalDragUpdate: (detail) {
                final RenderBox container =
                    context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dx > widget.positionLimit &&
                    pos.dx < (container.size.width - widget.positionLimit)) {
                  //TODO: 変更があったことを通知する必要がある
                  // weight.value = pos.dx / container.size.width;
                }
              },
              child: Container(color: _gripColor),
            ),
          ),
        ));
        left += widget.gripSize;
      }
      children.add(Positioned(
        left: left,
        width: viewsWidth * weight,
        top: 0,
        bottom: 0,
        child: child,
      ));
      left += (viewsWidth * weight);
    });

    return Stack(
      children: children,
    );
  }
}

class SplitViewController {
  UnmodifiableListView<double?> get weights => UnmodifiableListView(_weights);

  List<double?> _weights;

  SplitViewController._(this._weights);

  /// Creates a [SplitViewController]
  ///
  /// The [weights] specifies the ratio in the view. The sum of the [weights] cannot exceed 1.
  factory SplitViewController({List<double?>? weights}) {
    if (weights == null) {
      weights = List.empty(growable: true);
    }
    return SplitViewController._(weights);
  }
}

/// Arranges view order.
enum SplitViewMode {
  /// Arranges vertically.
  Vertical,

  /// Arranges horizontally.
  Horizontal,
}
