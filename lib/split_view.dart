library split_view;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// SplitView
class SplitView extends StatefulWidget {
  final Widget view1;
  final Widget view2;
  final SplitViewMode viewMode;
  final double gripSize;
  final double initialWeight;
  final Color gripColor;
  final double positionLimit;
  final ValueChanged<double> onWeightChanged;

  SplitView({
    Key key,
    @required this.view1,
    @required this.view2,
    @required this.viewMode,
    this.gripSize = 12.0,
    this.initialWeight = 0.5,
    this.gripColor = Colors.grey,
    this.positionLimit = 20.0,
    this.onWeightChanged,
  }) : super(key: key);

  @override
  State createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  double defaultWeight;
  ValueNotifier<double> weight;
  double _prevWeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.defaultWeight =
        PageStorage.of(context)?.readState(context, identifier: widget.key) ?? widget.initialWeight;
  }

  @override
  Widget build(BuildContext context) {
    weight = ValueNotifier(defaultWeight);
    _prevWeight = defaultWeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<double>(
          valueListenable: weight,
          builder: (_, w, __) {
            if (widget.onWeightChanged != null && _prevWeight != w) {
              _prevWeight = w;
              PageStorage.of(context)?.writeState(context, w, identifier: widget.key);
              widget.onWeightChanged(w);
            }
            if (widget.viewMode == SplitViewMode.Vertical) {
              return _buildVerticalView(context, constraints, w);
            } else {
              return _buildHorizontalView(context, constraints, w);
            }
          },
        );
      },
    );
  }

  Stack _buildVerticalView(BuildContext context, BoxConstraints constraints, double w) {
    final double top = constraints.maxHeight * w;
    final double bottom = constraints.maxHeight * (1.0 - w);
    final halfGripSize = widget.gripSize / 2.0;

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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (detail) {
                final RenderBox container = context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dy > widget.positionLimit &&
                    pos.dy < (container.size.height - widget.positionLimit)) {
                  weight.value = pos.dy / container.size.height;
                }
              },
              child: Container(color: widget.gripColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalView(BuildContext context, BoxConstraints constraints, double w) {
    final double left = constraints.maxWidth * w;
    final double right = constraints.maxWidth * (1.0 - w);
    final double halfGripSize = widget.gripSize / 2.0;

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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (detail) {
                final RenderBox container = context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dx > widget.positionLimit &&
                    pos.dx < (container.size.width - widget.positionLimit)) {
                  weight.value = pos.dx / container.size.width;
                }
              },
              child: Container(color: widget.gripColor),
            ),
          ),
        ),
      ],
    );
  }
}

enum SplitViewMode {
  Vertical,
  Horizontal,
}
