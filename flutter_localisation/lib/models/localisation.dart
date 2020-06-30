import 'package:flutterlocalisation/database/database_provider.dart';

class Localisation {
  int id;
  String latitude;
  String longitude;
  String time;

  Localisation({this.id, this.latitude, this.longitude, this.time});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_LATITUDE: latitude,
      DatabaseProvider.COLUMN_LONGITUDE: longitude,
      DatabaseProvider.COLUMN_TIME: time,
    };

    if(id != null){
      map[DatabaseProvider.COLUMN_ID] = id;
    }

    return map;
  }

  Localisation.fromMap(Map<String, dynamic> map){
    id = map[DatabaseProvider.COLUMN_ID];
    latitude = map[DatabaseProvider.COLUMN_LATITUDE];
    longitude = map[DatabaseProvider.COLUMN_LONGITUDE];
    time = map[DatabaseProvider.COLUMN_TIME];
  }
}