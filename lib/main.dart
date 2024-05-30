import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PalletCounterScreen(),
    );
  }
}

class PalletCounterScreen extends StatefulWidget {
  @override
  _PalletCounterScreenState createState() => _PalletCounterScreenState();
}

class _PalletCounterScreenState extends State<PalletCounterScreen> {
  List<List<List<bool>>> layers = [
    _generateLayer(3, 3),
    _generateLayer(3, 3),
    _generateLayer(3, 3),
  ];
  int boxesPerPallet = 10;
  int extraBoxes = 5;
  List<int> widths = [3, 3, 3];
  List<int> lengths = [3, 3, 3];

  static List<List<bool>> _generateLayer(int width, int length) {
    return List.generate(length, (_) => List.generate(width, (_) => true));
  }

  void updateLayer(int index, int width, int length) {
    setState(() {
      widths[index] = width;
      lengths[index] = length;

      if (widths[index] == 0) {
        layers[index] = [];
      } else {
        layers[index] = _generateLayer(widths[index], lengths[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pallet Counter'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display main squares
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        color: index == 0
                            ? Colors.red
                            : index == 1
                                ? Colors.blue
                                : Colors.green,
                        child: Text(
                          'Layer ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Width',
                            hintText: widths[index].toString(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int width = int.tryParse(value) ?? 0;
                            updateLayer(index, width, lengths[index]);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Length',
                            hintText: lengths[index].toString(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (widths[index] > 0) {
                              int length = int.tryParse(value) ?? 0;
                              updateLayer(index, widths[index], length);
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 400, // Adjusted width to fit 20 pallets
                        height: 400, // Adjusted height to fit 20 pallets
                        child: InteractiveViewer(
                          boundaryMargin: EdgeInsets.all(20.0),
                          minScale: 0.1,
                          maxScale: 5.0,
                          child: widths[index] == 0
                              ? Center(child: Text('Layer deactivated'))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: widths[index] * lengths[index],
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widths[index],
                                  ),
                                  itemBuilder: (context, subIndex) {
                                    int x = subIndex % widths[index];
                                    int y = subIndex ~/ widths[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          layers[index][y][x] =
                                              !layers[index][y][x];
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(4),
                                        color: layers[index][y][x]
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 20),
              // Data Board
              DataTable(
                columns: [
                  DataColumn(label: Text('Total Pallets')),
                  DataColumn(label: Text('Boxes per Pallet')),
                  DataColumn(label: Text('Sum')),
                  DataColumn(label: Text('Extra Boxes')),
                  DataColumn(
                    label: Text(
                      'Total Boxes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(getTotalPallets().toString())),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: boxesPerPallet.toString(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                boxesPerPallet = int.tryParse(value) ?? 10;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(Text(
                          (getTotalPallets() * boxesPerPallet).toString())),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: extraBoxes.toString(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                extraBoxes = int.tryParse(value) ?? 5;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          (getTotalPallets() * boxesPerPallet + extraBoxes)
                              .toString(),
                          style: TextStyle(
                            fontSize: 18, // Bigger font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getTotalPallets() {
    int total = 0;
    for (var layer in layers) {
      for (var row in layer) {
        total += row.where((pallet) => pallet).length;
      }
    }
    return total;
  }
}
