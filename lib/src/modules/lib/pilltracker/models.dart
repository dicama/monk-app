/// This is a model for the medication consumption time.
///
/// consumptionTime is the daytime of consumption in minutes starting everyday, if the consumptionCycle is day
/// otherwise consumptionTime is a single weekly consumption time in minutes starting from Monday 0 AM.
class MedicationConsumption {
  DateTime consumptionTime;
  DateTime consumptionTimeActually;
  double amount;
  bool isAsNeeded;

  MedicationConsumption(
      this.amount, this.consumptionTime, this.consumptionTimeActually,
      {this.isAsNeeded = false});

  Map toJson() {
    return {
      "consumptionTime": consumptionTime.toIso8601String(),
      "consumptionTimeActually": consumptionTimeActually.toIso8601String(),
      "amount": amount,
      "isAsNeeded": isAsNeeded,
    };
  }

  MedicationConsumption.fromJson(Map json) {
    amount = json["amount"];
    consumptionTime = DateTime.parse(json["consumptionTime"]);
    if (json.containsKey("consumptionTimeActually")) {
      consumptionTimeActually = DateTime.parse(json["consumptionTimeActually"]);
    } else {
      consumptionTimeActually = consumptionTime;
    }
    if (json.containsKey("isAsNeeded")) {
      isAsNeeded = json["isAsNeeded"];
    } else {
      isAsNeeded = false;
    }
  }
}

class MedicationTime {
  int consumptionTime;
  double amount;
  MedicationUnits units;

  Map toJson() {
    return {
      "consumptionTime": consumptionTime,
      "amount": amount,
      "units": units.index
    };
  }

  DateTime getMedicationTimeToday() {
    DateTime now = DateTime.now();
    DateTime dayStart = now
        .subtract(Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond))
        .add(Duration(minutes: consumptionTime % (24 * 60)));

    return dayStart;
  }

  MedicationTime.fromJson(Map json) {
    amount = json["amount"];
    consumptionTime = json["consumptionTime"];
    units = MedicationUnits.values[json["units"]];
  }

  MedicationTime(this.consumptionTime, this.amount, this.units);

  /// convert the consumption time to the hours of the day
  String toHours() {
    if (consumptionTime >= 0) {
      int dayMinutes = consumptionTime % (60 * 24);
      return (consumptionTime / 60).floor().toString() +
          ":" +
          (consumptionTime % 60).toString().padLeft(2, "0");
    } else {
      return "On Demand";
    }
  }
}

enum MedicationType { pill, capsule, syringe, powder, drops, cream }

const MedicationTypeStringsDE = [
  "Tablette",
  "Kapsel",
  "Spritze",
  "Pulver",
  "Tropfen",
  "Creme"
];

enum MedicationUnits {
  items,
  drops,
  mg,
  mug,
  g,
  ml,
}

const MedicationUnitsShortStringsDE = ["St", "Tr", "mg", "µg", "g", "ml"];

const MedicationUnitsStringsDE = ["Stück", "Tropfen", "mg", "µg", "g", "ml"];

enum MedicationAgentUnits { mug, mg, g, mgPerml, mugPerml }

const MedicationAgentUnitsStringsDE = ["µg", "mg", "g", "mg/ml", "µg/ml"];

const DayOfWeekShortStringsDE = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];

enum MedicationCycle { day, week }

const MedicationCycleStringsDE = ["Tag", "Woche"];

/// This is a model for the medication.
///
/// It holds all infromation required for the medication and keeps track of the medication consumption in the consumptionHistory
class Medication {
  List<MedicationTime> consumptionTimes;
  List<MedicationConsumption> consumptionHistory = [];
  MedicationCycle consumptionCycle;
  String name;
  String agent;
  MedicationType type;
  double availableUnits;
  double initalUnits;
  MedicationUnits unitsOfUnits;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String category;
  String notes = "";
  bool remind = true;
  bool isAsNeeded = false;

  Medication(this.name, this.agent, this.consumptionTimes, this.category,
      this.initalUnits, this.availableUnits);

  Medication.fromJson(Map json) {
    name = json["name"];
    agent = json["agent"];
    type = MedicationType.values[json["type"]];
    unitsOfUnits = MedicationUnits.values[json["unitsOfUnits"]];
    consumptionCycle = MedicationCycle.values[json["consumptionCycle"]];

    consumptionTimes = List<MedicationTime>.from(
        json["consumptionTimes"].map((e) => MedicationTime.fromJson(e)));

    consumptionHistory = List<MedicationConsumption>.from(
        json["consumptionHistory"]
            .map((e) => MedicationConsumption.fromJson(e)));
    availableUnits = json["availableUnits"];
    initalUnits = json["initalUnits"];
    startTime = DateTime.parse(json["startTime"]);
    endTime = DateTime.parse(json["startTime"]);
    category = json["category"];
    if (category == null) {
      category = "Allgemein";
    }
    notes = json["notes"];
    remind = json["remind"];
    isAsNeeded = json["isAsNeeded"];
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "agent": agent,
      "type": type.index,
      "unitsOfUnits": unitsOfUnits.index,
      "consumptionTimes": consumptionTimes.map((e) => e.toJson()).toList(),
      "consumptionHistory": consumptionHistory.map((e) => e.toJson()).toList(),
      "consumptionCycle": consumptionCycle.index,
      "availableUnits": availableUnits,
      "initalUnits": initalUnits,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "category": category,
      "notes": notes,
      "remind": remind,
      "isAsNeeded": isAsNeeded,
    };
  }

  DateTime getFittingConsumptionTimeToday(MedicationTime medTime) {
    MedicationConsumption mc = getFittingConsumptionToday(medTime);
    if (mc == null) {
      return null;
    } else {
      return mc.consumptionTime;
    }
  }

  bool wasTakenToday(MedicationTime medTime) {
    if (getFittingConsumptionToday(medTime) != null) {
      return true;
    } else {
      return false;
    }
  }

  bool wasTakenOnDay(MedicationTime medTime, DateTime day) {
    if (getFittingConsumptionOnDay(medTime, day) != null) {
      return true;
    } else {
      return false;
    }
  }

  List<MedicationConsumption> getAsNeededConsumptionOnDay(DateTime day) {
    DateTime startday = day;
    startday = startday.subtract(Duration(
        hours: startday.hour,
        minutes: startday.minute,
        seconds: startday.second,
        milliseconds: startday.millisecond,
        microseconds: startday.microsecond)); // make
    DateTime endday = startday.add(Duration(days: 1));
    List<MedicationConsumption> retVal = List();
    for (int n = consumptionHistory.length - 1; n >= 0; n--) {
      if (consumptionHistory[n].consumptionTime.isAfter(startday) &&
          consumptionHistory[n].consumptionTime.isBefore(endday)) {
        if (consumptionHistory[n].isAsNeeded) {
          retVal.add(consumptionHistory[n]);
        }
      } else if (consumptionHistory[n].consumptionTime.isBefore(startday)) {
        break;
      }
    }
    return retVal;
  }

  List<MedicationConsumption> getAsNeededConsumptionToday() {
    DateTime day = DateTime.now();

    return getAsNeededConsumptionOnDay(day);
  }

  MedicationConsumption getFittingConsumptionToday(MedicationTime medTime) {
    DateTime startday = DateTime.now();
    startday = startday
        .subtract(Duration(
            hours: startday.hour,
            minutes: startday.minute,
            seconds: startday.second,
            milliseconds: startday.millisecond,
            microseconds: startday.microsecond))
        .add(Duration(
            minutes: medTime.consumptionTime %
                (60 * 24))); // make sure it works also with week rythm

    for (int n = consumptionHistory.length - 1; n >= 0; n--) {
      if (consumptionHistory[n].isAsNeeded) {
        continue;
      }
      int tDiff =
          consumptionHistory[n].consumptionTime.difference(startday).inMinutes;

      if (tDiff < 120 && tDiff > -120) {
        if (consumptionHistory[n].amount == medTime.amount) {
          return consumptionHistory[n];
        }
      }

      if (tDiff < -1000) {
        break;
      }
    }
    return null;
  }

  MedicationConsumption getFittingConsumptionOnDay(
      MedicationTime medTime, DateTime day) {
    DateTime startday = day;
    startday = startday
        .subtract(Duration(
            hours: startday.hour,
            minutes: startday.minute,
            seconds: startday.second,
            milliseconds: startday.millisecond,
            microseconds: startday.microsecond))
        .add(Duration(
            minutes: medTime.consumptionTime %
                (60 * 24))); // make sure it works also with week rythm

    for (int n = consumptionHistory.length - 1; n >= 0; n--) {
      if (consumptionHistory[n].isAsNeeded) {
        continue;
      }
      int tDiff =
          consumptionHistory[n].consumptionTime.difference(startday).inMinutes;

      if (tDiff < 120 && tDiff > -120) {
        if (consumptionHistory[n].amount == medTime.amount) {
          return consumptionHistory[n];
        }
      }
      if (tDiff < -1000) {
        break;
      }
    }
    return null;
  }

  String getAllHoursAsString() {
    String retStr = "";
    consumptionTimes.sort((a, b) {
      return a.consumptionTime - b.consumptionTime;
    });

    consumptionTimes.forEach((element) {
      retStr += element.toHours() + " ";
    });

    return retStr;
  }
}
