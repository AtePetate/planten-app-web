import 'dart:async';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Plant> planten;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    planten = [
      Plant(
        "Perzische slaapboom 1",
        "Albizia julibrissin",
        "Een sierlijke boom afkomstig uit Azië, die 's nachts zijn bladeren sluit en prachtige roze bloemen produceert. Geschikt voor schaduwrijke tuinen en grote potten. Jonge bomen vragen een goed doorlatende grond en regelmatig water in het groeiseizoen om sterk te ontwikkelen.",
        0,
        "assets/albizia.png",
        [],
        [],
        2400,
      ),
      Plant(
        "Perzische slaapboom 2",
        "Albizia julibrissin",
        "Een sierlijke boom afkomstig uit Azië, die 's nachts zijn bladeren sluit en prachtige roze bloemen produceert. Geschikt voor schaduwrijke tuinen en grote potten. Jonge bomen vragen een goed doorlatende grond en regelmatig water in het groeiseizoen om sterk te ontwikkelen.",
        0,
        "assets/albizia.png",
        [],
        [],
        2400,
      ),
      Plant(
        "Perzische slaapboom 3",
        "Albizia julibrissin",
        "Een sierlijke boom afkomstig uit Azië, die 's nachts zijn bladeren sluit en prachtige roze bloemen produceert. Geschikt voor schaduwrijke tuinen en grote potten. Jonge bomen vragen een goed doorlatende grond en regelmatig water in het groeiseizoen om sterk te ontwikkelen.",
        0,
        "assets/albizia.png",
        [],
        [],
        2400,
      ),
      Plant(
        "Perzische slaapboom 4",
        "Albizia julibrissin",
        "Een sierlijke boom afkomstig uit Azië, die 's nachts zijn bladeren sluit en prachtige roze bloemen produceert. Geschikt voor schaduwrijke tuinen en grote potten. Jonge bomen vragen een goed doorlatende grond en regelmatig water in het groeiseizoen om sterk te ontwikkelen.",
        0,
        "assets/albizia.png",
        [],
        [],
        2400,
      ),
      Plant(
        "Anna Paulownaboom 1",
        "Paulownia tomentosa",
        "Een snelgroeiende boom, bekend om zijn grote bladeren en prachtige paarse bloemen. Ideaal voor het creëren van snelle schaduw en een tropische uitstraling. Jonge bomen hebben extra ondersteuning nodig bij harde wind en houden van voldoende water en zonlicht voor een krachtige groei.",
        0,
        "assets/paulownia.png",
        [],
        [],
        2000,
      ),
      Plant(
        "Anna Paulownaboom 2",
        "Paulownia tomentosa",
        "Een snelgroeiende boom, bekend om zijn grote bladeren en prachtige paarse bloemen. Ideaal voor het creëren van snelle schaduw en een tropische uitstraling. Jonge bomen hebben extra ondersteuning nodig bij harde wind en houden van voldoende water en zonlicht voor een krachtige groei.",
        0,
        "assets/paulownia.png",
        [],
        [],
        2000,
      ),
    ];


    startFetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchData();
    });
  }

  void startFetchData() async {
    await fetchData();
  }

  String classifyPerPlant(int percentage, int drempel) {
    if (percentage >= 75) {
      return "Zeer nat";
    } else if (percentage >= 50) {
      return "Vochtig";
    } else if (percentage >= 30) {
      return "Droog aan het worden";
    } else if (percentage >= 10) {
      return "Droog";
    } else {
      return "Kurk droog";
    }
  }

  String calcTrend(List<int> history) {
    if (history.isEmpty || history.length < 2) return "Geen trend";
    int diff = history.last - history.first;
    if (diff > 0) {
      return "Natter";
    } else if (diff < 0) {
      return "Droger";
    } else {
      return "Stabiel";
    }
  }

  Future<void> fetchData() async {
    try {
      final moistures = await ApiService.fetchMoistureData();

      for (int i = 0; i < planten.length; i++) {
        String sensorKey = 'sensor${i + 1}';
        String historyKey = 'history${i + 1}';

        if (moistures.containsKey(sensorKey)) {
          int percentage = moistures[sensorKey];
          planten[i].vochtigheid = percentage;
          planten[i].status = classifyPerPlant(percentage, planten[i].droogDrempel);
        }

        if (moistures.containsKey(historyKey)) {
          List<int> parsedHistory = List<int>.from(moistures[historyKey]);
          planten[i].history = parsedHistory;
          planten[i].trend = calcTrend(parsedHistory);
        }

        // ✅ Logs ophalen en toevoegen
        final logs = await ApiService.fetchLogs(planten[i].naam);
        planten[i].logboek = logs;
      }

      setState(() {});
    } catch (e) {
      developer.log("❌ Fout bij ophalen data: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ate's Forrest")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/leaves.png"),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 0.7,
          ),
          itemCount: planten.length,
          itemBuilder: (context, index) {
            final plant = planten[index];
            return PlantCard(
              plant: plant,
              onUpdated: () {
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
