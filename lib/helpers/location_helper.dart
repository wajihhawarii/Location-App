import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
    bool isServiceEnabled = await Geolocator
        .isLocationServiceEnabled(); //على الجهاز  GPS تختبر هل نحن مفعلين خدمة ال
    if (!isServiceEnabled) {
      await Geolocator
          .requestPermission(); //تطلب الاذن في الحصول على هذه السماحية
    }

    return await Geolocator.getCurrentPosition(
      //تجلب الموقع الحالي
      desiredAccuracy:
          LocationAccuracy.high, //تعبر عن مدة اهمية تنفيذ التعليمات السابقة
    );
  }
}
