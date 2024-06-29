import 'dart:async';
import 'package:city_location/business_logic/cubit/maps/maps_cubit.dart';
import 'package:city_location/business_logic/cubit/maps/maps_state.dart';
import 'package:city_location/constnats/my_colors.dart';
import 'package:city_location/data/models/Place_suggestion.dart';
import 'package:city_location/data/models/place.dart';
import 'package:city_location/data/models/place_directions.dart';
import 'package:city_location/helpers/location_helper.dart';
import 'package:city_location/presentation/widgets/distance_and_time.dart';
import 'package:city_location/presentation/widgets/my_drawer.dart';
import 'package:city_location/presentation/widgets/place_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  FloatingSearchBarController? controller =
      FloatingSearchBarController(); //this is cotroller for search appbar
  List<PlaceSuggestion> places = [];
  static Position? position;
  // ignore: unused_field
  final Completer<GoogleMapController> _mapController = Completer();
  // ignore: unused_field
  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 11,
  );

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      //استدعاء طريقة التي تجلب لنا الموقع الحالي من خلال الكلاس الموجود في الواحهة التانية
      setState(() {});
    });
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 18),
      queryStyle: const TextStyle(fontSize: 18),
      hint: 'Find a place..',
      border: const BorderSide(style: BorderStyle.none),
      margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      height: 52,
      iconColor: MyColors.blue,
      progress: progressIndicator,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      //progress: progressIndicator,
      onQueryChanged: (query) {
        //كلما تكتب حرف
        print("1111111111111111111111111111111111111111");
        getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {
        //عند النقر عليها
        print("3333333333333333333333333333");
        // hide distance and time row
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
              icon: Icon(Icons.place, color: Colors.black.withOpacity(0.6)),
              onPressed: () {}),
        ),
      ], //القائمة التي سوف تظهر عند الكتابة في مربع البحث
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              buildSelectedPlaceLocationBloc(),
              buildDiretionsBloc(),
            ],
          ),
        );
      },
    );
  }

//////////////////////////////////////////////////////////////////////////////////////

  Set<Marker> markers = {};
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace; //object from model
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;

  //مهمة هذه الدالة هي ان تتحرك للموقع الجديد التي سوف انتقل عليه
  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 13,
    );
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // these variables for getDirections
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  var isSearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget buildDiretionsBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is DirectionsLoaded) {
          placeDirections = (state).placeDirections;

          getPolylinePoints();
        }
      },
      child: Container(),
    );
  }

  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }
//*************************************************************/

  Widget buildSelectedPlaceLocationBloc() {
    //دالة من اجل عند جلب تفاصيل المكان الذاهب عليه
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;
          goToMySearchedForLocation();
          // getDirections();
        }
      },
      child: Container(),
    );
  }
//*************************************************************/

  void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }

//*************************************************************/
  Future<void> goToMySearchedForLocation() async {
    //دالة الذهاب الى المكان الجديد
    buildCameraNewPosition(); //احداثيات الكاميرا الجديدة
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        goToSearchedForPlace)); //تحريك الكاميرا الى المكان الجديد
    buildSearchedPlaceMarker(); //من اجل بناء العلامة في المكان الجديد
  }

//*************************************************************/
  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: const MarkerId('1'),
      onTap: () {
        buildCurrentLocationMarker(); //من اجل عند الضغط على علامة المكان الجديد تضع علامة في الموقع الحالي وهذا راي شخصي

        // show time and distance
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      //من اجل عند الضغط على علامة الموقع تظهر لنا تفاصيل الموقع
      infoWindow: InfoWindow(title: placeSuggestion.description),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed), //لون العلامة
    );
    addMarkerToMarkersAndUpdateUI(
        searchedPlaceMarker); //من اجل اضافة علامة الى قائمة العلامات
  }

//*************************************************************/
  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: const MarkerId('2'),
      onTap: () {},
      infoWindow: const InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(
        currentLocationMarker); //من اجل اضافة علامة الى قائمة العلامات
  }

//*************************************************************/
//من اجل اضافة علامة الى قائمة العلامات
  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }
  //*************************************************************/

  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4(); //يولد توكين عشوائي
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          places = (state).places; //اسناد الداتا من  واجهة تانية
          if (places.isNotEmpty) {
            return buildPlacesList(); //لو يوجد بيانات رجعت  من القائمة  رجعلي ياهن
          } else {
            return Container(
              height: 100,
              width: 100,
              color: Colors.red,
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildPlacesList() {
    return ListView.builder(
        itemBuilder: (ctx, index) {
          return InkWell(
            onTap: () async {
              placeSuggestion = places[
                  index]; //model اسندنا المكان الذي ضغطنا عليه الى غرض من
              controller!.close(); //نقفل شريط البحث عند الاغلاق
              getSelectedPlaceLocation(); //مهمتها الانتقال الى المكان التي انتقلت عليه
              polylinePoints.clear();
              removeAllMarkersAndUpdateUI();
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        },
        itemCount: places.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics());
  }

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }

  getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4(); //توليد رمز عشوائي
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }

  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true, //هي النقطة الزرقاء التى تعبر عن موقعك
      zoomControlsEnabled:
          true, //الازرار التي تظهر على الخريطو من اجل ان تعمل تقريب تبعيد
      myLocationButtonEnabled:
          false, // هو زر يظهر في اعلى الشاشة عند الضغط عليه يعيديني الى موقعي
      markers: markers,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                polylineId: const PolylineId('my_polyline'),
                color: Colors.black,
                width: 2,
                points: polylinePoints,
              ),
            }
          : {},
    );
  }

  //هذا الدالة تعيدنا الى الموقع الحالي تبعنا
  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  @override
  initState() {
    super.initState();
    getMyCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(), //غرض من ملف تاني
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: MyColors.blue,
          onPressed: _goToMyCurrentLocation,
          child: const Icon(Icons.place, color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null
              ? buildMap()
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
          isSearchedPlaceMarkerClicked
              ? DistanceAndTime(
                  isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                  placeDirections: placeDirections,
                )
              : Container(),
          buildFloatingSearchBar(), //functions to return search appbar
        ],
      ),
    );
  }
}
