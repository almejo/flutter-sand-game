import 'package:flutter/material.dart';
import 'package:sand_game/simulator.dart';

class SelectionScreen extends StatelessWidget {
  final CellType type;

  SelectionScreen({this.type});

  @override
  Widget build(BuildContext context) {
    return buildSelectionGrid(context);
  }

  Widget buildSelectionGrid(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Materials'),
        ),
        body: GridView.count(
          crossAxisCount: 5,
          children: List.generate(CellType.values.length, (index) {
            CellType type = CellType.values[index];
            return GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    color: type.color,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                        width: 5,
                        color: type == this.type
                            ? Colors.deepPurpleAccent
                            : Colors.grey)),
                child: Center(
                    child: Text(
                  '${type.name}',
                  style: TextStyle(
                      color:
                          type == CellType.NONE ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold),
                )),
              ),
              onTap: () => Navigator.pop(context, type),
            );
          }),
        ));
  }
}
