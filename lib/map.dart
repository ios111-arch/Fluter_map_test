import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;

class MapApp extends StatefulWidget {
  const MapApp({super.key, required this.title});

  final String title;

  @override
  State<MapApp> createState() => _MapApp();
}

class _MapApp extends State<MapApp> {
  double _latitude = 35.681;
  double _longitude = 139.767;
  String Now_location = '';
  List<CircleMarker> circleMarkers = [];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          //Twitterボタン
          SizedBox(
            width: 36,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 10,
                backgroundColor: Colors.amber[500],
                shape: CircleBorder(),
                padding: EdgeInsets.all(2),
              ),
              onPressed: () {
                getLocation();
                // initLocation();
              },
              child: Icon(
                Icons.refresh_sharp,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: FlutterMap(
        // マップ表示設定
        options: MapOptions(
          center: LatLng(_latitude, _longitude),
          //140にしたら地図が表示されなかった
          zoom: 14.0,
          interactiveFlags: InteractiveFlag.all,
          enableScrollWheel: true,
          scrollWheelVelocity: 0.00001,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.jp/{z}/{x}/{y}.png",
            userAgentPackageName: 'land_place',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: LatLng(_latitude, _longitude),
                builder: (ctx) => const FlutterLogo(
                  textColor: Colors.blue,
                  key: ObjectKey(Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getLocation() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('位置情報取得の権限がありません');
      return;
    }
    // 位置情報を取得
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      // 北緯がプラス、南緯がマイナス
      _latitude = position.latitude;
      // 東経がプラス、西経がマイナス
      _longitude = position.longitude;
      print('現在地の緯度は、$_latitude');
      print('現在地の経度は、$_longitude');
    });
    //取得した緯度経度からその地点の地名情報を取得する
    final placeMarks =
        await geoCoding.placemarkFromCoordinates(_latitude, _longitude);
    final placeMark = placeMarks[0];
    print("現在地の国は、${placeMark.country}");
    print("現在地の県は、${placeMark.administrativeArea}");
    print("現在地の市は、${placeMark.locality}");
    setState(() {
      Now_location = placeMark.locality ?? "現在地データなし";
      // ref.read(riverpodNowLocation.notifier).state = Now_location;
      print('現在地は、$Now_location');
    });
  }

  Future<void> initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final _latitude = position.latitude;
    final _longitude = position.longitude;
    initCircleMarker(_longitude, _longitude);
    setState(() {});
  }

  void initCircleMarker(double latitude, double longitude) {
    CircleMarker circleMarler = CircleMarker(
      color: Colors.indigo.withOpacity(0.9),
      radius: 10,
      borderColor: Colors.white.withOpacity(0.9),
      borderStrokeWidth: 3,
      point: LatLng(latitude, longitude),
    );
    circleMarkers.add(circleMarler);
  }
}
