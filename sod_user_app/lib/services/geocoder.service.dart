import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/address.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/coordinates.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geolocator/geolocator.dart';
export 'package:sod_user/models/address.dart';
export 'package:sod_user/models/coordinates.dart';

class GeocoderService extends HttpService {
//
  /// Factory method that reuse same instance automatically
  factory GeocoderService() => Singleton.lazy(() => GeocoderService._());

  /// Private constructor
  GeocoderService._() {}

  Future<List<Address>> findAddressesFromCoordinates(
    Coordinates coordinates, {
    int limit = 5,
  }) async {
    //use backend api
    //temporary set
    if (!AppMapSettings.useGoogleOnApp && !AppMapSettings.useVietMapOnApp) {
      final apiresult = await get(
        Api.geocoderForward,
        queryParameters: {
          "lat": coordinates.latitude,
          "lng": coordinates.longitude,
          "limit": limit,
        },
        forceRefresh: true,
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return (apiResponse.data).map((e) {
          // return Address().fromServerMap(e);
          Address address;
          try {
            address = Address().fromMap(e);
          } catch (error) {
            address = Address().fromServerMap(e);
          }
          return address;
        }).toList();
      }

      return [];
    }
    //use in-app geocoding
    if (AppMapSettings.isUsingVietmap) {
      //vietmap
      if (AppMapSettings.useVietMapOnApp) {
        final apiKey = AppStrings.vietMapMapApiKey;
        String url =
            "https://maps.vietmap.vn/api/reverse/v3?apikey=${apiKey}&lng=${coordinates.longitude}&lat=${coordinates.latitude}";

        final apiResult = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );

        final apiResponse = ApiResponse.fromResponse(apiResult);

        //
        if (apiResponse.allGood) {
          List<dynamic> apiResponseData = apiResponse.body;
          return (apiResponseData).map((e) {
            try {
              return Address().fromMap(e);
            } catch (error) {
              return Address().fromServerMap(e);
            }
          }).toList();
        }
        return [];
      }
    } else {
      //google
      if (AppMapSettings.useGoogleOnApp) {
        final apiKey = AppStrings.googleMapApiKey;
        String url =
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.toString()};key=$apiKey";

        final apiResult = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );

        final apiResponse = ApiResponse.fromResponse(apiResult);

        //
        if (apiResponse.allGood) {
          Map<String, dynamic> apiResponseData = apiResponse.body;
          return (apiResponseData["results"] as List).map((e) {
            try {
              return Address().fromMap(e);
            } catch (error) {
              return Address().fromServerMap(e);
            }
          }).toList();
        }
        return [];
      }
    }

    return [];
  }

  Future<List<Address>> findAddressesFromQuery(String address) async {
    //use in-app geocoding
    String myLatLng = "";
    if (LocationService.currenctAddress != null) {
      myLatLng = "${LocationService.currenctAddress?.coordinates?.latitude},";
      myLatLng += "${LocationService.currenctAddress?.coordinates?.longitude}";
    }

    //get current device region
    String? region;
    try {
      region = await Utils.getCurrentCountryCode();
    } catch (error) {
      region = "";
    }

    //use backend api
    if (!AppMapSettings.useGoogleOnApp && !AppMapSettings.useVietMapOnApp) {
      final apiresult = await get(
        Api.geocoderReserve,
        queryParameters: {
          "keyword": address,
          "location": myLatLng,
          "region": region,
        },
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return (apiResponse.data).map((e) {
          Address address;
          try {
            address = Address().fromMap(e);
          } catch (error) {
            address = Address().fromServerMap(e);
          }
          if (AppMapSettings.isUsingVietmap) {
            address.gMapPlaceId = e["ref_id"];
          } else {
            address.gMapPlaceId = e["place_id"] ?? "";
          }
          return address;
        }).toList();
      }

      return [];
    }
    //use in-app geocoding
    if (AppMapSettings.isUsingVietmap) {
      if (AppMapSettings.useVietMapOnApp) {
        final apiKey = AppStrings.vietMapMapApiKey;
        String url =
            "https://maps.vietmap.vn/api/autocomplete/v3?apikey=${apiKey}&text=${address}&circle_center=${myLatLng}&layers=ADDRESS";
        final result = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );

        final apiResult = ApiResponse.fromResponse(result);

        //
        if (apiResult.allGood) {
          //
          List<dynamic> apiResponse = apiResult.body;
          return apiResponse.map((e) {
            Address address;
            try {
              address = Address().fromMap(e);
            } catch (error) {
              address = Address().fromServerMap(e);
            }
            address.gMapPlaceId = e["ref_id"];
            return address;
          }).toList();
        }
        return [];
      }
    } else {
      if (AppMapSettings.useGoogleOnApp) {
        final apiKey = AppStrings.googleMapApiKey;
        address = address.replaceAll(" ", "+");
        String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$address;key=$apiKey;location=$myLatLng;region=$region";
        final result = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );

        final apiResult = ApiResponse.fromResponse(result);

        //
        if (apiResult.allGood) {
          //
          Map<String, dynamic> apiResponse = apiResult.body;
          return (apiResponse["predictions"] as List).map((e) {
            Address address;
            try {
              address = Address().fromMap(e);
            } catch (error) {
              address = Address().fromServerMap(e);
            }
            address.gMapPlaceId = e["place_id"];
            return address;
          }).toList();
        }
        return [];
      }
    }

    return [];
  }

  Future<Address> fecthPlaceDetails(Address address) async {
    //use backend api
    if (!AppMapSettings.useGoogleOnApp && !AppMapSettings.useVietMapOnApp) {
      final apiresult = await get(
        Api.geocoderPlaceDetails,
        queryParameters: {
          "place_id": address.gMapPlaceId,
          "plain": true,
        },
      );

      //
      final apiResponse = ApiResponse.fromResponse(apiresult);
      if (apiResponse.allGood) {
        return Address().fromPlaceDetailsMap(apiResponse.body as Map);
      }

      return address;
    }

    //use in-app geocoding
    if (AppMapSettings.isUsingVietmap) {
      if (AppMapSettings.useVietMapOnApp) {
        final apiKey = AppStrings.vietMapMapApiKey;
        String url =
            "https://maps.vietmap.vn/api/place/v3?apikey=${apiKey}&refid=${address.gMapPlaceId}";
        final result = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );
        final apiResult = ApiResponse.fromResponse(result);

        //
        if (apiResult.allGood) {
          Map<String, dynamic> apiResponse = apiResult.body;
          address = address.fromPlaceDetailsMap(apiResponse);
          return address;
        }
        throw "Failed".tr();
      }
    } else {
      if (AppMapSettings.useGoogleOnApp) {
        final apiKey = AppStrings.googleMapApiKey;
        String url =
            "https://maps.googleapis.com/maps/api/place/details/json?fields=address_component,formatted_address,name,geometry;place_id=${address.gMapPlaceId};key=$apiKey";
        final result = await get(
          Api.externalRedirect,
          queryParameters: {"endpoint": url},
        );
        final apiResult = ApiResponse.fromResponse(result);

        //
        if (apiResult.allGood) {
          Map<String, dynamic> apiResponse = apiResult.body;
          address = address.fromPlaceDetailsMap(apiResponse["result"]);
          return address;
        }
        throw "Failed".tr();
      }
    }

    return Address();
  }

  static Future<PlacesDetailsResponse?> placeSelectAPI(
      BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: AppStrings.googleMapApiKey,
      mode: Mode.overlay,
      onError: (response) {
        print('>>>error home controller: ${response.errorMessage}');
      },
      language: "vi",
      types: [],
      strictbounds: false,
      components: [],
    );
    return displayPrediction(p);
  }

  static Future<PlacesDetailsResponse?> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces? places = GoogleMapsPlaces(
        apiKey: AppStrings.googleMapApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse? detail = await places
          .getDetailsByPlaceId(p.placeId.toString(), language: "vi");
      return detail;
    }
    return null;
  }

  static Future<dynamic> getDurationDistance(
      LatLng departureLatLong, LatLng destinationLatLong) async {
    //vietmapcheck
    double originLat, originLong, destLat, destLong;
    originLat = departureLatLong.latitude;
    originLong = departureLatLong.longitude;
    destLat = destinationLatLong.latitude;
    destLong = destinationLatLong.longitude;
    String url;
    http.Response restaurantToCustomerTime;

    if (AppMapSettings.isUsingVietmap) {
      url =
          'https://maps.vietmap.vn/api/matrix?api-version=1.1&apikey=${AppStrings.vietMapMapApiKey}&point=$originLat,$originLong&point=$destLat,$destLong';
      restaurantToCustomerTime = await http.get(Uri.parse(url));
    } else {
      url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
      restaurantToCustomerTime = await http.get(Uri.parse(
          '$url?units=metric&origins=$originLat,$originLong&destinations=$destLat,$destLong&key=${AppStrings.googleMapApiKey}'));
    }

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);
    if (AppMapSettings.isUsingVietmap) {
      if (decodedResponse['code'] == 'OK') {
        return decodedResponse;
      }
    } else {
      if (decodedResponse['status'] == 'OK' &&
          decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
        return decodedResponse;
      }
    }
    return null;
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print("Error: GeocoderService().determinePosition()");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print("Error: GeocoderService().determinePosition()");
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print("Error: GeocoderService().determinePosition()");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
