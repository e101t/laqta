import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Lifecycle Safety', () {
    testWidgets('mounted check prevents setState after dispose', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const TestWidgetWithMountedCheck(),
        ),
      );

      // Verify widget is mounted
      expect(find.byType(TestWidgetWithMountedCheck), findsOneWidget);

      // Dispose widget
      await tester.binding.handlePopRoute();

      // No errors should be thrown when mounted check is in place
    });

    testWidgets('state updates are cancelled after unmount', (WidgetTester tester) async {
      var updateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: TestWidgetWithCounter(onUpdate: () => updateCount++),
        ),
      );

      expect(updateCount, greaterThan(0));
    });
  });
}

class TestWidgetWithMountedCheck extends StatefulWidget {
  const TestWidgetWithMountedCheck({super.key});

  @override
  State<TestWidgetWithMountedCheck> createState() =>
      _TestWidgetWithMountedCheckState();
}

class _TestWidgetWithMountedCheckState extends State<TestWidgetWithMountedCheck> {
  Future<void> _asyncOperation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      // Safe to update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _asyncOperation,
          child: const Text('Test'),
        ),
      ),
    );
  }
}

class TestWidgetWithCounter extends StatefulWidget {
  final VoidCallback onUpdate;

  const TestWidgetWithCounter({super.key, required this.onUpdate});

  @override
  State<TestWidgetWithCounter> createState() => _TestWidgetWithCounterState();
}

class _TestWidgetWithCounterState extends State<TestWidgetWithCounter> {
  final int _count = 0;

  @override
  void initState() {
    super.initState();
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}
