import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://esp32-flask-server-8psf.onrender.com/sensor_data';
  static const String logUrl = 'https://esp32-flask-server-8psf.onrender.com/log';
  static const String logsBaseUrl = 'https://esp32-flask-server-8psf.onrender.com/logs';

  /// ✅ Ophalen sensor- en historydata
  static Future<Map<String, dynamic>> fetchMoistureData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<String, dynamic> result = {};

      // Stel hier je nieuwe natte grens en droge grens in
      const int wetThreshold = 600; // lager dan dit is 100% nat
      const int dryThreshold = 4095; // hoger dan dit is 0%

      data.forEach((key, value) {
        if (key.startsWith('sensor') && value is int) {
          int rawValue = value;
          int percentage;

          if (rawValue <= wetThreshold) {
            percentage = 100;
          } else if (rawValue >= dryThreshold) {
            percentage = 0;
          } else {
            double mapped = ((dryThreshold - rawValue).toDouble() / (dryThreshold - wetThreshold)) * 100;
            percentage = mapped.clamp(0, 100).toInt();
          }

          result[key] = percentage;
        } 
        else if (key.startsWith('history') && value is List) {
          List<int> historyPercentages = value.map((entry) {
            if (entry is Map && entry.containsKey('value')) {
              int raw = entry['value'];
              int perc;

              if (raw <= wetThreshold) {
                perc = 100;
              } else if (raw >= dryThreshold) {
                perc = 0;
              } else {
                double mapped = ((dryThreshold - raw).toDouble() / (dryThreshold - wetThreshold)) * 100;
                perc = mapped.clamp(0, 100).toInt();
              }

              return perc;
            } else {
              return 0;
            }
          }).toList();
          result[key] = historyPercentages;
        }
      });
      return result;
    } else {
      throw Exception('Fout bij ophalen data: ${response.statusCode}');
    }
  }

  /// ✅ Logregel naar server sturen
  static Future<void> sendLog(String plantName, String logEntry) async {
    try {
      final response = await http.post(
        Uri.parse(logUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'plant_name': plantName, 'log': logEntry}),
      );

      if (response.statusCode != 200) {
        throw Exception('Fout bij verzenden log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netwerkfout bij verzenden log: $e');
    }
  }

  /// ✅ Logs ophalen per plant (als lijst van mapjes)
  static Future<List<Map<String, String>>> fetchLogs(String plantName) async {
    try {
      final response = await http.get(Uri.parse('$logsBaseUrl/$plantName'));

      if (response.statusCode == 200) {
        final List<dynamic> logsData = json.decode(response.body);
        return logsData.map<Map<String, String>>((entry) {
          if (entry is Map) {
            return {
              'date': entry['date'].toString(),
              'entry': entry['entry'].toString(),
            };
          } else {
            return {'date': '', 'entry': entry.toString()};
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Netwerkfout bij ophalen logs: $e');
    }
  }
}
