import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sand_game/sand_canvas.dart';
import 'package:sand_game/selection_screen.dart';

import 'simulator.dart';

void main() {
  runApp(SandApp());
}

class SandApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sand Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sand Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CellType _type = CellType.SAND;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(children: [SandCanvas(material: _type)]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await askMaterial(context);
        },
        tooltip: 'Materials',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future askMaterial(BuildContext context) async {
    CellType result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectionScreen(type: _type),
        ));
    if (result == null) {
      result = CellType.NONE;
    }
    setState(() {
      _type = result;
    });
  }
}
