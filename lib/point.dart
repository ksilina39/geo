import 'package:yandex_mapkit/yandex_mapkit.dart';

class ExtendedPoint extends Point {
  final String name;

  const ExtendedPoint({
    required this.name,
    required super.latitude,
    required super.longitude,
  });
}