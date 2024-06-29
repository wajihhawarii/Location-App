import 'package:city_location/business_logic/cubit/maps/maps_state.dart';
import 'package:city_location/data/repository/maps_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapsInitial());

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.fetchSuggestions(place, sessionToken).then((suggestions) {
      //البيانات التي سوف ترجع من السيرفر
      emit(PlacesLoaded(suggestions));
    });
  }

//تفاصيل عن المكان الذي نريده وهي خدمة مدفوعة
  void emitPlaceLocation(String placeId, String sessionToken) {
    mapsRepository.getPlaceLocation(placeId, sessionToken).then((place) {
      emit(PlaceLocationLoaded(place));
    });
  }

  void emitPlaceDirections(LatLng origin, LatLng destination) {
    mapsRepository.getDirections(origin, destination).then((directions) {
      emit(DirectionsLoaded(directions));
    });
  }
}
