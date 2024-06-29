import 'package:city_location/data/models/Place_suggestion.dart';
import 'package:city_location/data/models/place.dart';
import 'package:city_location/data/models/place_directions.dart';
import 'package:city_location/data/webservices/places_webservices.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsRepository {
  final PlacesWebservices
      placesWebservices; //اخذنا غرض من كلاس الذي يحوي التوابع التي سوف ترسل الطلبات الى السيرفر
  MapsRepository(this.placesWebservices);

  Future<List<PlaceSuggestion>> fetchSuggestions(
      String place, String sessionToken) async {
    final suggestions = await placesWebservices.fetchSuggestions(
        place, sessionToken); //اسناد البينات التي عائدة من السيرف
    return suggestions
        .map((suggestion) =>
            PlaceSuggestion.fromJson(suggestion)) // model  اسناد البيانات الى
        .toList();
  }

  Future<Place> getPlaceLocation(String placeId, String sessionToken) async {
    final place = await placesWebservices.getPlaceLocation(
        placeId, sessionToken); //البيانات التي سوف ترجع من السيرفر
    // var readyPlace = Place.fromJson(place);
    return Place.fromJson(place);
  }

  Future<PlaceDirections> getDirections(
      LatLng origin, LatLng destination) async {
    final directions =
        await placesWebservices.getDirections(origin, destination);

    return PlaceDirections.fromJson(directions);
  }
}
