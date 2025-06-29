import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DynamicPieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color>? colorList;

  const DynamicPieChart({
    Key? key,
    required this.dataMap,
    this.colorList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = colorList ??
        [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.yellow,
        ];

    final sections = <PieChartSectionData>[];
    int index = 0;
    dataMap.forEach((label, value) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: "${label}\n${value.toStringAsFixed(1)}",
          radius: 70,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 32,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}