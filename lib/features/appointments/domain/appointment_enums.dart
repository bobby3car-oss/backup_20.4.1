enum AppointmentType { followUp, physio, surgery, call, imaging, other }

enum AppointmentStatus { planned, done, canceled }

enum ReminderPreset {
  none,
  atTime,
  min15,
  min30,
  hour1,
  hours2,
  day1,
  days2,
  custom,
}

enum RepeatRule { none, daily, weekly, monthly }
