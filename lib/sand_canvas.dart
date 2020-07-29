import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sand_game/simulator.dart';

class SandCanvas extends StatefulWidget {
  final CellType material;

  SandCanvas({this.material});

  @override
  _SandCanvasState createState() => _SandCanvasState();
}

class _SandCanvasState extends State<SandCanvas> {
  Simulator simulator = Simulator(100, 100);
  Timer timer;
  var _ticks = 10000;
  var _milliseconds = 50;

  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: _milliseconds), (timer) {
      simulator.tick(_ticks);
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
          onVerticalDragStart: (details) => setMaterial(details),
          onHorizontalDragUpdate: (details) => setMaterial(details),
          onTapDown: (details) => setMaterial(details),
          child: Container(
              width: 500,
              height: 500,
              child: CustomPaint(
                painter: MyPainter(simulator: simulator),
                child: Container(),
              ))),
      Row(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: Text(
              'Ticks per interval',
              textAlign: TextAlign.center,
            )),
        Slider(
          min: 0,
          max: 50000,
          value: _ticks.toDouble(),
          onChanged: (value) {
            setState(() {
              _ticks = value.toInt();
            });
          },
        )
      ]),
      Row(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: Text(
              'Interval milliseconds',
              textAlign: TextAlign.center,
            )),
        Slider(
          min: 5,
          max: 100,
          value: _milliseconds.toDouble(),
          onChanged: (value) {
            _milliseconds = value.toInt();
            timer.cancel();
            timer = Timer.periodic(
                Duration(milliseconds: _milliseconds.toInt()), (timer) {
              simulator.tick(_ticks);
              setState(() {});
            });
          },
        )
      ]),
    ]);
  }

  void setMaterial(details) {
    simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5, widget.material);
    simulator.setMaterial(details.localPosition.dx ~/ 5 + 1,
        details.localPosition.dy ~/ 5, widget.material);
    simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5 + 1, widget.material);
    simulator.setMaterial(details.localPosition.dx ~/ 5 - 1,
        details.localPosition.dy ~/ 5, widget.material);
    simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5 - 1, widget.material);
  }
}

class MyPainter extends CustomPainter {
  Simulator simulator;

  MyPainter({this.simulator});

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }

  paint(Canvas canvas, Size size) {
    for (int i = 0; i < simulator.width; i++) {
      for (int j = 0; j < simulator.height; j++) {
        Rect myRect = Offset(i * 5.0, j * 5.0) & Size(5.0, 5.0);
        final paint = Paint()
          ..color = simulator.getCellType(i, j).color
          ..strokeWidth = 4;
        canvas.drawRect(myRect, paint);
      }
    }
  }
}
