import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate App Icon', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;

    // Load material icons font
    // By default, flutter_test uses a dummy font. We need the real one.
    // Try to load from the project or we just use a trick:
    
    final Widget iconWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 1024,
        height: 1024,
        decoration: BoxDecoration(
          color: const Color(0xFF283593),
          borderRadius: BorderRadius.circular(200),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 200,
              child: Icon(
                Icons.account_balance,
                size: 500,
                color: Colors.white,
              ),
            ),
            const Positioned(
              bottom: 120,
              child: Text(
                'CK',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 250,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      RepaintBoundary(
        child: iconWidget,
      ),
    );

    final finder = find.byType(RepaintBoundary);
    final RenderObject renderObject = tester.renderObject(finder);
    final ui.Image image = await (renderObject as dynamic).toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final file = File('assets/icon/app_icon.png');
      file.createSync(recursive: true);
      file.writeAsBytesSync(byteData.buffer.asUint8List());
    }
  });
}
