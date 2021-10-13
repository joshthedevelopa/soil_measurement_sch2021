import 'dart:convert';

import 'package:http/http.dart' as http;
import 'imports.dart';

class ApiServices {
  static Future<Status> getMeasurements() async {
    Uri uri = Uri(
      scheme: "https",
      host: "api.thingspeak.com",
      path: "channels/1483213/feeds.json",
      queryParameters: {
        "api_key": "X9ZPCPAPZZWW8XXI",
        "results": "20",
      },
    );

    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        Map _map = jsonDecode(response.body);

        return Status(
          code: "OK",
          message: "Data Retrieved successfully",
          data: (_map['feeds'] as List).map((e) {
            return SoilData.fromMap(e);
          }).toList(),
        );
      } else {
        return Status(code: "ERROR", message: "");
      }
    } catch (e) {
      return Status(
        code: "ERROR",
        message: "Error Ocurred: $e!!",
      );
    }
  }
}
