import 'package:city_location/data/models/Place_suggestion.dart';
import 'package:city_location/data/models/place.dart';
import 'package:city_location/data/models/place_directions.dart';

abstract class MapsState {}

class MapsInitial extends MapsState {}

class PlacesLoaded extends MapsState {
  final List<PlaceSuggestion> places;

  PlacesLoaded(this.places);
}

class PlaceLocationLoaded extends MapsState {
  final Place place;
  PlaceLocationLoaded(this.place);
}

class DirectionsLoaded extends MapsState {
  final PlaceDirections placeDirections;

  DirectionsLoaded(this.placeDirections);
}
