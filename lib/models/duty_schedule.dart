class DutySchedule {
  final String id;
  final String pharmacyId;
  final String pharmacyName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isDayDuty;
  final String notes;

  DutySchedule({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.isDayDuty = false,
    this.notes = '',
  });

  factory DutySchedule.fromJson(Map<String, dynamic> json) {
    return DutySchedule(
      id: json['id'] ?? '',
      pharmacyId: json['pharmacyId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      isActive: json['isActive'] ?? false,
      isDayDuty: json['isDayDuty'] ?? false,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'isDayDuty': isDayDuty,
      'notes': notes,
    };
  }

  bool get isDutyNow {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}
