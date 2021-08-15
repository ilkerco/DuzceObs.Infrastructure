import 'package:flutter/material.dart';
import 'package:obsProject/notifiers/ders_notifier.dart';
import 'package:obsProject/notifiers/user_notifier.dart';
import 'package:obsProject/services/api/DuzceObsApi.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DersProgramiScreen extends StatefulWidget {
  @override
  _DersProgramiScreenState createState() => _DersProgramiScreenState();
}

class _DersProgramiScreenState extends State<DersProgramiScreen> {
  DersNotifier dersNotifier;
  @override
  void initState() {
    print("DersProgrami page cagrildi");
    dersNotifier = Provider.of<DersNotifier>(context, listen: false);
    if (Provider.of<UserNotifier>(context, listen: false)
            .CurrentUser
            .userType ==
        "Instructor") {
    } else {
      print(Provider.of<UserNotifier>(context, listen: false)
          .CurrentUser
          .userType);
      getAllDersByStudent(
              Provider.of<UserNotifier>(context, listen: false), dersNotifier)
          .then((value) {
        if (value) {
          setState(() {});
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: SfCalendar(
        view: CalendarView.workWeek,
        scheduleViewSettings: ScheduleViewSettings(appointmentItemHeight: 70),
        dataSource: _getCalendarDataSource(
            dersNotifier), //MeetingDataSource(_getDataSource()),
        timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 7,
            endHour: 24,
            nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
      )),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 8, 30, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 1)),
        endTime.add(const Duration(days: 1)), const Color(0xFF0F8644), false));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 1)),
        endTime.add(const Duration(days: 1)), const Color(0xFF0F8644), false));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 2)),
        endTime.add(const Duration(days: 2)), const Color(0xFF0F8644), false));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 3)),
        endTime.add(const Duration(days: 3)), const Color(0xFF0F8644), false));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 4)),
        endTime.add(const Duration(days: 4)), const Color(0xFF0F8644), false));
    meetings.add(Meeting('Conference', startTime.add(const Duration(days: 5)),
        endTime.add(const Duration(days: 5)), const Color(0xFF0F8644), false));
    return meetings;
  }
}

_AppointmentDataSource _getCalendarDataSource(DersNotifier dersNotifier) {
  List<Appointment> appointments = <Appointment>[];
  final DateTime today = DateTime.now();

  for (int i = 0; i < dersNotifier.dersList.length; i++) {
    var gg_hour = dersNotifier.dersList[i].startTime.toString().substring(0, 2);
    final DateTime startTime = DateTime(
        today.year - 1, today.month, today.day, int.parse(gg_hour), 00, 0);
    print(gg_hour);
    print(dersNotifier.dersList[i].endTime);
    var gg = gunToFreq(dersNotifier.dersList[i].startDay);
    appointments.add(Appointment(
        startTime: startTime,
        endTime: startTime.add(Duration(hours: 2)),
        subject: dersNotifier.dersList[i].dersKodu +
            " - " +
            dersNotifier.dersList[i].dersAdi,
        color: Colors.blue,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=$gg;INTERVAL=1;COUNT=100'));
  }
  //MO,
  /*List<Appointment> appointments = <Appointment>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 8, 30, 0);
  appointments.add(Appointment(
      startTime: startTime,
      endTime: startTime.add(Duration(hours: 2)),
      subject: 'Meeting',
      color: Colors.blue,
      recurrenceRule: 'FREQ=WEEKLY;BYDAY=MO;INTERVAL=1;COUNT=100'));*/

  return _AppointmentDataSource(appointments);
}

String gunToFreq(String gun) {
  if (gun == "Pazartesi") {
    return "MO";
  } else if (gun == "Salı") {
    return "TUE";
  } else if (gun == "Çarşamba") {
    return "WED";
  } else if (gun == "Perşembe") {
    return "THU";
  } else {
    return "FRI";
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
