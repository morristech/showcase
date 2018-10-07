import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './golden_boundary.dart';

Future<Uint8List> capturePng(WidgetTester tester, GlobalKey key) async {
  final RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  final ui.Image image = await boundary.toImage();
  final ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<File> writeToFile(String path, Uint8List imageBytes) async {
  final File output = File(path)..createSync(recursive: true);
  return await output.writeAsBytes(imageBytes);
}

Future<void> makeTest(Widget widget, int index,
    {ContainerBuilder customContainerBuilder, String outDir}) async {
  final String strIndex = index.toString().padLeft(3, '0');
  testWidgets('[$strIndex] Showcasing ${widget.toString()}',
      (WidgetTester tester) async {
    // https://github.com/flutter/flutter/issues/17738#issuecomment-392237064
    await tester.runAsync(() async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(GoldenBoundary(
        globalKey: key,
        child: widget,
        customContainerBuilder: customContainerBuilder,
      ));

      final Uint8List screenshotBytes = await capturePng(tester, key);
      await writeToFile(
          '${outDir ?? 'showcase'}/${strIndex}_${widget.toString()}.png',
          screenshotBytes);
    });
  });
}

void showcaseWidgets(List<Widget> widgets,
    {ContainerBuilder customContainerBuilder, String outDir}) {
  widgets.asMap().forEach((int index, Widget widget) => makeTest(widget, index,
      customContainerBuilder: customContainerBuilder, outDir: outDir));
}
