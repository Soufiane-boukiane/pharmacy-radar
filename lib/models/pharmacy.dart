class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final bool isDuty;
  final bool isDayDuty;
  final bool isPermanent;
  final double rating;
  final String? distance;
  final String? openingHours;
  final String? website;
  final String? dutyStartTime;
  final String? dutyEndTime;
  final String scheduleType; // 'normal' or 'continuous'

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
    this.isDuty = false,
    this.isDayDuty = false,
    this.isPermanent = false,
    this.rating = 0.0,
    this.distance,
    this.openingHours,
    this.website,
    this.dutyStartTime,
    this.dutyEndTime,
    this.scheduleType = 'normal',
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] ?? true,
      isDuty: json['isDuty'] ?? false,
      isDayDuty: json['isDayDuty'] ?? false,
      isPermanent: json['isPermanent'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance'],
      openingHours: json['openingHours'],
      website: json['website'],
      dutyStartTime: json['dutyStartTime'],
      dutyEndTime: json['dutyEndTime'],
      scheduleType: json['scheduleType'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isOpen': isOpen,
      'isDuty': isDuty,
      'isDayDuty': isDayDuty,
      'isPermanent': isPermanent,
      'rating': rating,
      'distance': distance,
      'openingHours': openingHours,
      'website': website,
      'dutyStartTime': dutyStartTime,
      'dutyEndTime': dutyEndTime,
      'scheduleType': scheduleType,
    };
  }

  Pharmacy copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isDuty,
    bool? isDayDuty,
    bool? isPermanent,
    String? distance,
    String? openingHours,
    String? website,
    double? rating,
    String? dutyStartTime,
    String? dutyEndTime,
    String? scheduleType,
  }) {
    return Pharmacy(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      isDuty: isDuty ?? this.isDuty,
      isDayDuty: isDayDuty ?? this.isDayDuty,
      isPermanent: isPermanent ?? this.isPermanent,
      distance: distance ?? this.distance,
      openingHours: openingHours ?? this.openingHours,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      dutyStartTime: dutyStartTime ?? this.dutyStartTime,
      dutyEndTime: dutyEndTime ?? this.dutyEndTime,
      scheduleType: scheduleType ?? this.scheduleType,
    );
  }
}
