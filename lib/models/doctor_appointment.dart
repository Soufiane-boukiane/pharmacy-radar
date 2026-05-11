import 'package:equatable/equatable.dart';

class DoctorAppointment extends Equatable {
  final String id;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;

  const DoctorAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [id, doctorName, specialty, date, time];

  DoctorAppointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? date,
    String? time,
  }) {
    return DoctorAppointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}
