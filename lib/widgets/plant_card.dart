import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';
import '../screens/detail_screen.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onUpdated;

  const PlantCard({super.key, required this.plant, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    // Haal laatste entry tekst op (zonder datum tonen op kaart)
    String laatsteEntry = "Nog geen logboek";
    if (plant.logboek.isNotEmpty && plant.logboek.last.containsKey('entry')) {
      laatsteEntry = plant.logboek.last['entry']!;
    }

    return Card(
      color: Colors.green.shade50.withAlpha((0.9 * 255).toInt()),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailScreen(plant: plant)),
          );
          onUpdated();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                plant.afbeelding,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                plant.naam,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text("${plant.vochtigheid}% vocht", style: GoogleFonts.poppins()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: LinearProgressIndicator(
                value: plant.vochtigheid / 100,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                laatsteEntry,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Status: ${plant.status.isNotEmpty ? plant.status : "Onbekend"} (${plant.trend.isNotEmpty ? plant.trend : "Geen trend"})",
                style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
