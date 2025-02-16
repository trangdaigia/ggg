class CarRentalPeriod {
  Time total;
  Time start_time;
  Time end_time;
  DateTime start_day;
  DateTime end_day;
  String type;
  CarRentalPeriod({
    required this.start_time,
    required this.end_time,
    required this.start_day,
    required this.end_day,
    required this.total,
    required this.type,
  });
  DateTime getStartDateTime() {
    return DateTime(
      start_day.year,
      start_day.month,
      start_day.day,
      start_time.hours,
      start_time.minute,
    );
  }

  DateTime getEndDateTime() {
    return DateTime(
      end_day.year,
      end_day.month,
      end_day.day,
      end_time.hours,
      end_time.minute,
    );
  }
}

class Time {
  int minute;
  int hours;
  Time({required this.hours, required this.minute});
  int getTotalMinutes() {
    return (hours * 60) + minute;
  }
}
