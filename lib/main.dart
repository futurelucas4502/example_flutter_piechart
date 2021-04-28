import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _data;
  @override
  Widget build(BuildContext context) {
    Widget pieChart = MyPieChart(
      [
        charts.Series<PieData, List>(
          id: 'Attendance',
          data: [
            new PieData("Absent", charts.MaterialPalette.red.shadeDefault,
                ["thing", "thing2", "thing3", "thing4"]),
            new PieData("Attended", charts.MaterialPalette.cyan.shadeDefault,
                ["thing5", "thing6", "thing7", "thing8", "thing9"]),
          ],
          domainFn: (PieData data, _) => data.data,
          measureFn: (PieData data, _) => data.data.length,
          labelAccessorFn: (PieData data, _) => data.label,
          colorFn: (PieData data, _) => data.colour,
        ),
      ],
      title: 'Flutter Demo Home Page',
      onSelected: (newData) {
        setState(() {
          _data = newData;
        });
      },
    );
    return Scaffold(
      body: ListView(
        children: [
          pieChart,
          _data == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(_data.toString()),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("hmm 2"),
                          )
                        ],
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}

// Custom data type:
class PieData {
  final String label;
  final charts.Color colour;
  final List data;

  PieData(this.label, this.colour, this.data);
}

class MyPieChart extends StatefulWidget {
  MyPieChart(this.seriesList, {Key key, this.title, @required this.onSelected})
      : super(key: key);
  final List<charts.Series> seriesList;
  final String title;
  final Function onSelected;

  @override
  _MyPieChartState createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  String _percentage;
  bool _animate = true;

  @override
  Widget build(BuildContext context) {
    _selected(charts.SelectionModel model, BuildContext context) {
      final selectedDatum = model.selectedDatum;
      for (var item in selectedDatum) {
        setState(() {
          _percentage = item.datum.data.length.toString() + "%";
          _animate =
              false; // prevent pie chart doing draw animation when things are clicked
        });
        widget.onSelected(item.datum.data);
      }
    }

    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: Center(child: Text(_percentage ?? "")),
        ),
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: charts.PieChart(
            widget.seriesList, // the pie charts data
            // Configure the width of the pie slices to 60px. The remaining space in
            // the chart will be left as a hole in the center that will be filled with the percentage.
            animate: _animate,
            defaultRenderer: charts.ArcRendererConfig(
              arcWidth: 60,
              arcRendererDecorators: [
                charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.outside,
                ),
              ],
            ),
            selectionModels: [
              charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: (charts.SelectionModel model) => _selected(
                    model,
                    context), // run the selected function when a section is clicked
              ),
            ],
            behaviors: [charts.DomainHighlighter()],
          ),
        ),
      ],
    );
  }
}
