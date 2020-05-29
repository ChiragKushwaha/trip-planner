import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const apiKey = "AIzaSyAl5pIkYK3uGuG1VEECnT9BSFZgmUPFAmA";

class GoogleMapsServices{
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2)async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }

  Future<List>getPlacesLocationPoints(LatLng initialPosition, String type) async{
      String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${initialPosition.latitude},${initialPosition.longitude}&radius=5500&type=$type&keyword=$type&key=$apiKey";
      http.Response response = await http.get(url);
      Map values = jsonDecode(response.body);
      return values["results"];

  }
  Future<String> getRouteWithWaypointsCoordinates(LatLng l1, LatLng l2, String address)async{
    print("Called");
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}8&destination=${l2.latitude},${l2.longitude}&waypoints=optimize:true|$address&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    print(values);
    return values["routes"][0]["overview_polyline"]["points"];
  }
}

