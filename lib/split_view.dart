library split_view;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A SplitView class.
class SplitView extends StatefulWidget {
  static const Color defaultGripColor = Colors.grey;
  static const Color defaultGripColorActive = Color.fromARGB(0xff, 0x66, 0x66, 0x66);
  static const double defaultGripSize = 12.0;
  static const double defaultInitialWeight = 0.5;
  static const double defaultPositionLimit = 20.0;

  /// The [view1] is first view.
  final Widget view1;

  /// The [view2] is second view.
  final Widget view2;

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

  /// Creates an [SplitView].
  SplitView({
    Key? key,
    required this.view1,
    required this.view2,
    required this.viewMode,
    this.gripSize = defaultGripSize,
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
  double? defaultWeight;
  late ValueNotifier<double?> weight;
  double? _prevWeight;
  late Color _gripColor;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.defaultWeight =
        PageStorage.of(context)?.readState(context, identifier: widget.key) ?? widget.initialWeight;
    weight = ValueNotifier(defaultWeight);
    _gripColor = widget.gripColor;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<double?>(
          valueListenable: weight,
          builder: (_, w, __) {
            if (widget.onWeightChanged != null && _prevWeight != w) {
              _prevWeight = w;
              PageStorage.of(context)?.writeState(context, w, identifier: widget.key);
              widget.onWeightChanged!(w);
            }
            if (widget.viewMode == SplitViewMode.Vertical) {
              return _buildVerticalView(context, constraints, w!);
            } else {
              return _buildHorizontalView(context, constraints, w!);
            }
          },
        );
      },
    );
  }

  Stack _buildVerticalView(BuildContext context, BoxConstraints constraints, double w) {
    double top = constraints.maxHeight * w;
    double bottom = constraints.maxHeight * (1.0 - w);
    final halfGripSize = widget.gripSize / 2.0;

    if (widget.maxHeightSidebar != null && top > widget.maxHeightSidebar!) {
      top = widget.maxHeightSidebar!;
      bottom = constraints.maxHeight - widget.maxHeightSidebar!;
    } else if (widget.minHeightSidebar != null && top < widget.minHeightSidebar!) {
      top = widget.minHeightSidebar!;
      bottom = constraints.maxHeight - widget.minHeightSidebar!;
    }

    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: bottom + halfGripSize,
          child: widget.view1,
        ),
        Positioned(
          top: top + halfGripSize,
          left: 0,
          right: 0,
          bottom: 0,
          child: widget.view2,
        ),
        Positioned(
          top: top - halfGripSize,
          left: 0,
          right: 0,
          bottom: bottom - halfGripSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            onEnter: (event) {
              setState(() {
                _gripColor = widget.gripColorActive;
              });
            },
            onExit: (_) {
              if (_dragging == false) setState(() => _gripColor = widget.gripColor);
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
                final RenderBox container = context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dy > widget.positionLimit &&
                    pos.dy < (container.size.height - widget.positionLimit)) {
                  weight.value = pos.dy / container.size.height;
                }
              },
              child: Container(color: _gripColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalView(BuildContext context, BoxConstraints constraints, double w) {
    double left = constraints.maxWidth * w;
    double right = constraints.maxWidth * (1.0 - w);
    final double halfGripSize = widget.gripSize / 2.0;

    if (widget.maxWidthSidebar != null && left > widget.maxWidthSidebar!) {
      left = widget.maxWidthSidebar!;
      right = constraints.maxWidth - widget.maxWidthSidebar!;
    } else if (widget.minWidthSidebar != null && left < widget.minWidthSidebar!) {
      left = widget.minWidthSidebar!;
      right = constraints.maxWidth - widget.minWidthSidebar!;
    }

    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: right + halfGripSize,
          bottom: 0,
          child: widget.view1,
        ),
        Positioned(
          top: 0,
          left: left + halfGripSize,
          right: 0,
          bottom: 0,
          child: widget.view2,
        ),
        Positioned(
          top: 0,
          left: left - halfGripSize,
          right: right - halfGripSize,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (event) {
              setState(() {
                _gripColor = widget.gripColorActive;
              });
            },
            onExit: (_) {
              if (_dragging == false) setState(() => _gripColor = widget.gripColor);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragDown: (details) {
                _dragging = true;
                _gripColor = widget.gripColorActive;
              },
              onHorizontalDragEnd: (details) {
                _dragging = false;
                setState(() => _gripColor = widget.gripColor);
              },
              onHorizontalDragUpdate: (detail) {
                final RenderBox container = context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dx > widget.positionLimit &&
                    pos.dx < (container.size.width - widget.positionLimit)) {
                  weight.value = pos.dx / container.size.width;
                }
              },
              child: Container(color: _gripColor),
            ),
          ),
        ),
      ],
    );
  }
}

/// Arranges view order.
enum SplitViewMode {
  /// Arranges vertically.
  Vertical,

  /// Arranges horizontally.
  Horizontal,
}
