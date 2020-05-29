import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/requests/google_maps_requests.dart';


class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  LatLng destinationRestaurant;
  String sendAddress="";

  AppState() {
    _getUserLocation();
    _loadingInitialPosition();
  }
// ! TO GET THE USERS LOCATION
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    print("the latitude is: ${position.latitude} and th longitude is: ${position.longitude} ");
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].name;

    notifyListeners();
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.clear();
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 5,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.blue));
    notifyListeners();
  }

  // ! ADD A MARKER ON THE MAO
  void _addMarker(LatLng location, String address) {
    sendAddress="";
    _markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: InfoWindow(
            title: address,
            snippet: "go here",
        ),
        icon: BitmapDescriptor.defaultMarker),);
    notifyListeners();
  }


  void _addMarkerRestaurant(LatLng location, String name, String address, String placeId) {
    _markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        onTap: (){
          print(name);
        },
        infoWindow: InfoWindow(
          title: name,
          snippet: address,
          onTap: (){
            addWayPoint(address);
          },
        ),
        icon: BitmapDescriptor.defaultMarker
    ),
    );
    notifyListeners();
  }

  // ! CREATE LAGLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    print(points.length);
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }

    print(result.length);
    findPoints(result);
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }
  void findPoints(List<LatLng> result) {
    List<LatLng> searchPoints= <LatLng>[];
    for(int i= 0 ;i < result.length;i+=30){
      searchPoints.add(result[i]);
    }
    restaurantsAlongYourRoute(searchPoints);notifyListeners();
  }
  // ! SEND REQUEST
  void sendRequest(String intendedLocation) async {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    print(destination);
    destinationRestaurant= LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);
    notifyListeners();
  }

  Future<void> restaurantsAlongYourRoute(List<LatLng> position) async {
    List<List> startPointNearbyPlaces = <List> [];

  for(LatLng d in position) {
     startPointNearbyPlaces.add( await _googleMapsServices.getPlacesLocationPoints(LatLng(d.latitude, d.longitude), "tourists location"));
  }

  print(startPointNearbyPlaces.length);
 int ans = await markerLocation(startPointNearbyPlaces);
 print(ans);notifyListeners();
  }
  Future<int> markerLocation(List<List> startPointNearbyPlaces) async {
    List<LatLng> markersPoints= <LatLng>[];
    List<String> address = <String> [];
    List<String> name = <String> [];
    List<String> placeId =<String> [];
    for (int j = 0; j < startPointNearbyPlaces.length; j++){
      print(j);
      List a = startPointNearbyPlaces[j] ;
      for(int i= 0; i< a.length;i ++){
        name.add(a[i]["name"]);
        address.add(a[i]["vicinity"]);
        placeId.add(a[i]["place_id"]);
        markersPoints.add(LatLng(a[i]["geometry"]["location"]["lat"],a[i]["geometry"]["location"]["lng"]));
      }
      print(a.length);
    }
    putMarkers(markersPoints, name, address, placeId);notifyListeners();
    return 1;
  }
  void putMarkers(List<LatLng> markersPoints, List<String> name, List<String> address,List<String> placeId) {
    for (int i = 0; i < markersPoints.length; i++){
      LatLng d = markersPoints[i];
      _addMarkerRestaurant(LatLng(d.latitude, d.longitude), name[i], address[i], placeId[i]);
    }notifyListeners();
  }
  // ! ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  // ! ON CREATE
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

//  LOADING INITIAL POSITION
  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(_initialPosition == null){
        locationServiceActive = false;
        notifyListeners();
      }
    });

  }
  Future<void> sendRequestConnectRestaurant(String address) async {
//    ####################################################################
//    _markers.clear();
//    _getUserLocation();
//    _loadingInitialPosition();
//    _addMarker(destinationRestaurant, "Go Here");
//    ####################################################################
    String route = await _googleMapsServices.getRouteWithWaypointsCoordinates(
        _initialPosition, destinationRestaurant, address);
    createRoute(route);
    notifyListeners();
  }


  void addWayPoint(String address) {

    if (sendAddress == ""){
      sendAddress = "$address";
    }else{
      sendAddress = "$sendAddress|$address";
    }
    print(sendAddress);
    sendRequestConnectRestaurant(sendAddress);
    print("Exited waypoint");
    notifyListeners();

  }
}
