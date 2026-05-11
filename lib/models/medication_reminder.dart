import 'package:equatable/equatable.dart';

class MedicationReminder extends Equatable {
  final String id;
  final String medicineName;
  final String time;
  final bool isActive;

  const MedicationReminder({
    required this.id,
    required this.medicineName,
    required this.time,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, medicineName, time, isActive];

  MedicationReminder copyWith({
    String? id,
    String? medicineName,
    String? time,
    bool? isActive,
  }) {
    return MedicationReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
    );
  }
}
