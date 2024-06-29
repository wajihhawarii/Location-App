import 'package:city_location/business_logic/cubit/maps/maps_cubit.dart';
import 'package:city_location/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:city_location/data/repository/maps_repo.dart';
import 'package:city_location/data/webservices/places_webservices.dart';
import 'package:city_location/presentation/screens/map_screen.dart';
import 'package:city_location/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'constnats/strings.dart';
import 'presentation/screens/login_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;
  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (BuildContext context) =>
                MapsCubit(MapsRepository(PlacesWebservices())),
            child: const MapScreen(),
          ),
        );

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: LoginScreen(),
          ),
        );

      case "/":
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: OtpScreen(phoneNumber: phoneNumber),
          ),
        );
    }
    return null;
  }
}
