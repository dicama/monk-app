import 'package:flutter_svg/flutter_svg.dart';

enum MonkIcon {
  daytimeMorning,
  daytimeNoon,
  daytimeEvening,
  daytimeNight,

}

class MonkIconLib
{

  static final daytimeMorning = SvgPicture.asset("assets/icons/pool/daytime/morning.svg");
  static final daytimeNoon = SvgPicture.asset("assets/icons/pool/daytime/noon.svg");
  static final daytimeEvening = SvgPicture.asset("assets/icons/pool/daytime/evening.svg");
  static final daytimeNight = SvgPicture.asset("assets/icons/pool/daytime/night.svg");
  static final medicationOnDemand = SvgPicture.asset("assets/icons/pool/medication/ondemand.svg");
  static final medicationPills = SvgPicture.asset("assets/icons/pool/medication/pills.svg");
}