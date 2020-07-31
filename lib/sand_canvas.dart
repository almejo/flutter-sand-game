import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sand_game/simulator.dart';

class SandCanvas extends StatefulWidget {
  final CellType material;

  final double width;

  final double height;

  SandCanvas({this.material, this.width, this.height});

  @override
  _SandCanvasState createState() => _SandCanvasState();
}

class _SandCanvasState extends State<SandCanvas> {
  Simulator _simulator = new Simulator(100, 100);
  Timer _timer;
  var _ticks = 10000;
  var _milliseconds = 50;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds: _milliseconds), (timer) {
      _simulator.tick(_ticks);
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _simulator.resizeWidth(widget.width ~/ 5.0);
    return Column(children: [
      GestureDetector(
          onVerticalDragStart: (details) => setMaterial(details),
          onHorizontalDragUpdate: (details) => setMaterial(details),
          onTapDown: (details) => setMaterial(details),
          child: Container(
              width: widget.width,
              height: 500,
              child: CustomPaint(
                painter: SandPainter(simulator: _simulator),
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
            _timer.cancel();
            _timer = Timer.periodic(
                Duration(milliseconds: _milliseconds.toInt()), (timer) {
              _simulator.tick(_ticks);
              setState(() {});
            });
          },
        ),
      ]),
      RaisedButton.icon(
          onPressed: _showClearDialog,
          icon: Icon(Icons.delete),
          label: Text('Delete'))
    ]);
  }

  void setMaterial(details) {
    _simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5, widget.material);
    _simulator.setMaterial(details.localPosition.dx ~/ 5 + 1,
        details.localPosition.dy ~/ 5, widget.material);
    _simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5 + 1, widget.material);
    _simulator.setMaterial(details.localPosition.dx ~/ 5 - 1,
        details.localPosition.dy ~/ 5, widget.material);
    _simulator.setMaterial(details.localPosition.dx ~/ 5,
        details.localPosition.dy ~/ 5 - 1, widget.material);
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Clear all"),
          content:
              new Text("Are you sure you want to clear the board? This cannot be undone"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _simulator.clear();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

class SandPainter extends CustomPainter {
  Simulator simulator;

  SandPainter({this.simulator});

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
