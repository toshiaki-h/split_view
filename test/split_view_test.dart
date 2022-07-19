import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split_view/split_view.dart';

void main() {
  testWidgets('controller', (tester) async {
    final controller = SplitViewController(weights: [0.1, 0.3, 0.6]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SplitView(
            gripSize: 10,
            controller: controller,
            viewMode: SplitViewMode.Horizontal,
            children: [
              Container(key: ValueKey(0)),
              Container(key: ValueKey(1)),
              Container(key: ValueKey(2)),
            ],
          ),
        ),
      ),
    );

    final totalWidth = tester.getSize(find.byType(SplitView)).width - 2 * 10;

    expect(tester.getSize(find.byKey(ValueKey(0))).width, totalWidth * 0.1);
    expect(tester.getSize(find.byKey(ValueKey(1))).width, totalWidth * 0.3);
    expect(tester.getSize(find.byKey(ValueKey(2))).width, totalWidth * 0.6);

    controller.weights = [0.1, 0.4, 0.5];
    await tester.pump();

    expect(tester.getSize(find.byKey(ValueKey(0))).width, totalWidth * 0.1);
    expect(tester.getSize(find.byKey(ValueKey(1))).width, totalWidth * 0.4);
    expect(tester.getSize(find.byKey(ValueKey(2))).width, totalWidth * 0.5);
  });
}
