import "package:flutter_polyline_points/flutter_polyline_points.dart";
import "package:http/http.dart" as http;
import "dart:convert" as convert;

class LocationService {
  // Google API key, must seperate this in a seperate credentials file later/
  final String key = "AIzaSyBTTVYQCtLpJGbVC66vSifekX5b3WAmz9U";

  // gets directions for two points using google directions API
  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key";

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var results = {
      "bounds_ne": json["routes"][0]["bounds"]["northeast"],
      "bounds_sw": json["routes"][0]["bounds"]["southwest"],
      "start_location": json["routes"][0]["legs"][0]["start_location"],
      "end_location": json["routes"][0]["legs"][0]["end_location"],
      "polyline": json["routes"][0]["overview_polyline"]["points"],
      "polyline_decoded": PolylinePoints()
          .decodePolyline(json["routes"][0]["overview_polyline"]["points"]),
    };

    //print(results); //avoid in production

    return results;
  }
}
