import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'point.dart';

class YandexMapPage extends StatefulWidget {
  const YandexMapPage({Key? key}) : super(key: key);

  @override
  State<YandexMapPage> createState() => _YandexMapPageState();
}

class _YandexMapPageState extends State<YandexMapPage> {
  final _location = Location();
  final List<MapObject> _mapObjects = [];
  late YandexMapController _controller;
  final MapObjectId _mapObjectId = const MapObjectId('raw_icon_placemark');
  late final Uint8List _placemarkIcon;
  Point? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yandex Map page"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              // Виджет для отрисовки Яндекс карты
              child: YandexMap(
                mapObjects: _mapObjects, // объекты, которые будут на карте
                onMapCreated: _onMapCreated, // метод, который вызывает при создании. через него мы получаем контроллер
                onMapTap: _addMarker, // обработчик нажатия на карту
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          final point = _selectedPoint;
          if (point == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ни одна точка не выбрана'),
                backgroundColor: Colors.red,
              ),);
              return;
        }
        showGeneralDialog(
          context: context,
           pageBuilder: (_, __, ___) {
             final nameController = TextEditingController();
              return AlertDialog(
                 title: const Text('New location'),
                 content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                  ],
                 ),
                  actions: [
                     TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.pop(
                          context,
                          ExtendedPoint(
                            name: nameController.text,
                            latitude: point.latitude,
                            longitude: point.longitude,
                          ),
                        );
                      },
                      child:const Text('Save'),
                     ),
                  ],
              );
           });
        },
        child: const Icon(Icons.save),),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMapCreated(YandexMapController controller) {
    _controller = controller;
    _checkLocationPermission();
  }

  _checkLocationPermission() async {
    bool locationServiceEnabled = await _location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await _location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    PermissionStatus locationForAppStatus = await _location.hasPermission();
    if (locationForAppStatus == PermissionStatus.denied) {
      await _location.requestPermission();
      locationForAppStatus = await _location.hasPermission();
      if (locationForAppStatus != PermissionStatus.granted) {
        return;
      }
    }
    // Получаем текущую локацию
    LocationData locationData = await _location.getLocation();
    // Рисуем точку для отметки на карте
    _placemarkIcon = await _rawPlacemarkImage();
    // Определяем точку с текущей позицией
    final point = Point(latitude: locationData.latitude!, longitude: locationData.longitude!);
    // Добавляем маркер
    await _addMarker(point);
    // Двигаем камеру к точке
    await _controller.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: point)), 
      animation: const MapAnimation(duration: 1, type: MapAnimationType.smooth));
  }

  Future _addMarker(Point point) async {
    _mapObjects.add(
      // PlacemarkMapObject означает отметку на карте в виде обычной точки
      PlacemarkMapObject(
        mapId: _mapObjectId,
        point: point,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(_placemarkIcon),
          ),
        ),
      ),
    );
    setState(() {
      _selectedPoint = point; //
    });
  }

  Future<Uint8List> _rawPlacemarkImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(50, 50);
    final fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const radius = 20.0;

    final circleOffset = Offset(size.height / 2, size.width / 2);

    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);

    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }
}