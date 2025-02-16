import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sod_user/driver_lib/constants/app_map_settings.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;

class MapUtils {
  //
  static targetBounds(LatLng locNE, LatLng locSW) {
    var nLat, nLon, sLat, sLon;

    if (locSW.latitude <= locNE.latitude) {
      sLat = locSW.latitude;
      nLat = locNE.latitude;
    } else {
      sLat = locNE.latitude;
      nLat = locSW.latitude;
    }
    if (locSW.longitude <= locNE.longitude) {
      sLon = locSW.longitude;
      nLon = locNE.longitude;
    } else {
      sLon = locNE.longitude;
      nLon = locSW.longitude;
    }

    if (AppMapSettings.isUsingVietmap) {
      return vietMapGl.LatLngBounds(
        northeast: vietMapGl.LatLng(nLat, nLon),
        southwest: vietMapGl.LatLng(sLat, sLon),
      );
    } else {
      return LatLngBounds(
        northeast: LatLng(nLat, nLon),
        southwest: LatLng(sLat, sLon),
      );
    }
  }
}
