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

  testWidgets('rebuild', (tester) async {
    final controller1 = SplitViewController(weights: [0.2, 0.8]);
    final controller2 = SplitViewController(weights: [0.4, 0.6]);

    Future<void> pumpSplitView(SplitViewController controller) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitView(
              gripSize: 10,
              controller: controller,
              viewMode: SplitViewMode.Horizontal,
              indicator: const SizedBox.shrink(key: Key('indicator')),
              children: [
                Container(key: ValueKey(0)),
                Container(key: ValueKey(2)),
              ],
            ),
          ),
        ),
      );
    }

    await pumpSplitView(controller1);

    expect(controller1.weights, [0.2, 0.8]);
    expect(controller2.weights, [0.4, 0.6]);

    final indicator = find.ancestor(
      of: find.byKey(const Key('indicator')),
      matching: find.byType(Container),
    );
    expect(indicator, findsOneWidget);

    // drag to the right (controller1)
    await tester.drag(indicator, Offset(10, 0));

    final weights1 = controller1.weights;
    expect(weights1.first, greaterThan(0.2));
    expect(weights1.last, lessThan(0.8));
    expect(controller2.weights, [0.4, 0.6]);

    await pumpSplitView(controller2);

    // drag to the left (controller2)
    await tester.drag(indicator, Offset(-20, 0));

    expect(controller1.weights, equals(weights1));
    final weights2 = controller2.weights;
    expect(weights2.first, lessThan(0.4));
    expect(weights2.last, greaterThan(0.6));
  });

  group('SplitViewController.weights defensive copy', () {
    test('setter should not be affected by external mutation of the original list', () {
      final controller = SplitViewController(weights: [0.5, 0.5]);
      final externalList = <double?>[0.3, 0.7];

      controller.weights = externalList;
      expect(controller.weights, [0.3, 0.7]);

      // Mutate the original list externally
      externalList[0] = 0.9;
      externalList[1] = 0.1;

      // Controller's weights should remain unchanged
      expect(controller.weights, [0.3, 0.7]);
    });

    test('setter should not be affected by adding elements to the original list', () {
      final controller = SplitViewController(weights: [0.5, 0.5]);
      final externalList = <double?>[0.3, 0.7];

      controller.weights = externalList;
      expect(controller.weights, [0.3, 0.7]);

      // Add element to the original list externally
      externalList.add(0.0);

      // Controller's weights should remain unchanged
      expect(controller.weights, [0.3, 0.7]);
      expect(controller.weights.length, 2);
    });

    test('constructor should not be affected by external mutation of the original list', () {
      final externalWeights = <double?>[0.4, 0.6];
      final controller = SplitViewController(weights: externalWeights);

      expect(controller.weights, [0.4, 0.6]);

      // Mutate the original list externally
      externalWeights[0] = 0.9;
      externalWeights[1] = 0.1;

      // Controller's weights should remain unchanged
      expect(controller.weights, [0.4, 0.6]);
    });

    testWidgets('setter with List<double> (non-nullable) should work with _init expansion', (tester) async {
      final controller = SplitViewController();

      // Set weights as List<double> (non-nullable) with fewer items than children
      controller.weights = <double?>[0.5];

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
              ],
            ),
          ),
        ),
      );

      // _init should expand the list with null values and calculate weights
      expect(controller.weights.length, 2);
      expect(controller.weights[0], 0.5);
      expect(controller.weights[1], 0.5);
    });
  });
}
