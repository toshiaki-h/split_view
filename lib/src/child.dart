import 'package:flutter/widgets.dart';

class SplitViewChild extends StatelessWidget {
  final Widget child;

  SplitViewChild({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
