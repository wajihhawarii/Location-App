import 'package:city_location/constnats/strings.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesWebservices {
  late Dio dio;

  PlacesWebservices() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      receiveDataWhenStatusError: true,
    );
    dio = Dio(options);
  }

  Future<List<dynamic>> fetchSuggestions(
      String place, String sessionToken) async {
    try {
      Response response = await dio.get(
        suggestionsBaseUrl,
        queryParameters: {
          //هذه البيانات سوف ترسل مع الرابط
          'input': place,
          'types': 'address',
          'components': 'country:eg',
          'key': googleAPIKey,
          'sessiontoken': sessionToken
        },
      );
      // response.data;   هذه البيانات التي سوف ترجع من السيرفر
      if ((response.data["predictions"] as List).isEmpty) {
        return jsonList["predictions"];
      }
      return response.data['predictions'];
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  //خاص بالمكان وهذه خدمة مدفوعة  id تجلب تفاصيل عن المكان التى نريدمن خلال

  Future<dynamic> getPlaceLocation(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(
        placeLocationBaseUrl,
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': googleAPIKey,
          'sessiontoken': sessionToken
        },
      );
      return response.data;
    } catch (error) {
      return Future.error("Place location error : ",
          StackTrace.fromString(('this is its trace')));
    }
  }

  // origin equals current location
  // destination equals searched for location
  //origin = currentLocation

//هذه الدالة من اجل رسم الخطوط بين مكانين
  Future<dynamic> getDirections(LatLng origin, LatLng destination) async {
    try {
      Response response = await dio.get(
        directionsBaseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': googleAPIKey,
        },
      );
      print(response.data);
      return response.data;
    } catch (error) {
      return Future.error("Place location error : ",
          StackTrace.fromString(('this is its trace')));
    }
  }
}

Map<String, dynamic> jsonList = {
  "status": "REQUEST_DENIED",
  "error_message": "You must enable Billing on the Google Cloud Project",
  "predictions": [
    {
      "description": "Saudi",
      "matched_substrings": [
        {"length": 9, "offset": 0}
      ],
      "place_id": "sada",
      "reference": "asdasdasdas",
      "structured_formatting": {
        "main_text": "Al Zmalek",
        "main_text_matched_substrings": [
          {"length": 9, "offset": 0}
        ],
        "secondary_text": "Berket an Nase, Al salam first"
      }
    },
    {
      "description": "Syria",
      "matched_substrings": [
        {"length": 9, "offset": 0}
      ],
      "place_id": "sada",
      "reference": "asdasdasdas",
      "structured_formatting": {
        "main_text": "Al Zmalek",
        "main_text_matched_substrings": [
          {"length": 9, "offset": 0}
        ],
        "secondary_text": "Berket an Nase, Al salam first"
      }
    },
    {
      "description": "Swesra",
      "matched_substrings": [
        {"length": 9, "offset": 0}
      ],
      "place_id": "sada",
      "reference": "asdasdasdas",
      "structured_formatting": {
        "main_text": "Al Zmalek",
        "main_text_matched_substrings": [
          {"length": 9, "offset": 0}
        ],
        "secondary_text": "Berket an Nase, Al salam first"
      }
    }
  ]
};
