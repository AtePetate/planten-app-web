import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/plant.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Plant plant;
  const DetailScreen({super.key, required this.plant});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await ApiService.fetchLogs(widget.plant.naam);
    setState(() {
      widget.plant.logboek.clear();
      widget.plant.logboek.addAll(logs);
    });
  }

  Future<void> _sendLogToServer(String plantName, String logEntry) async {
    final now = DateTime.now();
    final formatted = DateFormat('dd-MM-yyyy HH:mm').format(now);

    final newLog = {
      'date': formatted,
      'entry': logEntry,
    };

    await ApiService.sendLog(plantName, "$formatted - $logEntry");

    setState(() {
      widget.plant.logboek.add(newLog);
      _logController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plant.naam, style: GoogleFonts.poppins())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.plant.afbeelding),
            const SizedBox(height: 16),
            Text(widget.plant.naam, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.plant.wetenschappelijkeNaam, style: GoogleFonts.poppins(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(widget.plant.beschrijving, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            Text("Vochtigheid: ${widget.plant.vochtigheid}%", style: GoogleFonts.poppins()),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.plant.history
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Logboek:", style: GoogleFonts.poppins()),
            if (widget.plant.logboek.isEmpty)
              Text("Nog geen logboek", style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic))
            else
              ...widget.plant.logboek.map((log) {
                if (log.containsKey('entry')) {
                  return Text("- ${log['entry']}", style: GoogleFonts.poppins(fontSize: 12));
                  } else {
                  return Text("- ${log.toString()}", style: GoogleFonts.poppins(fontSize: 12));
                  }
              }),
            TextField(
              controller: _logController,
              decoration: const InputDecoration(labelText: "Nieuwe logregel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_logController.text.isNotEmpty) {
                  _sendLogToServer(widget.plant.naam, _logController.text);
                }
              },
              child: const Text("Logregel toevoegen"),
            )
          ],
        ),
      ),
    );
  }
}
