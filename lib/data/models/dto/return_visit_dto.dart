import 'package:jama/data/models/dto/dto.dart';

class ReturnVisitDto extends DTO {
  static const String _columnId = "ReturnVisitId";
  static const String _columnName = "Name";
  static const String _columnNotes = "RvNotes";
  static const String _columnImage = "ImagePath";
  static const String _columnGender = "Gender";
  static const String _columnLastVisitDate = "LastVisitDate";
  static const String _columnLastVisitId = "FK_Visit_ReturnVisit_LastVisit";
  static const String _columnPinned = "Pinned";
  static const String _columnStreet = "StreetAddress";
  static const String _columnCity = "City";
  static const String _columnState = "StateOrDistrict";
  static const String _columnPostalCode = "PostalCode";
  static const String _columnCountry = "Country";
  static const String _columnLatitude = "Latitude";
  static const String _columnLongitude = "Longitude";

  /// The [street] of the return visit.
  final String street;

  /// The [city] of the return visit.
  final String city;

  /// The [state] of the return visit.
  final String state;

  /// The [country] of the return visit.
  final String country;

  /// The [postalCode] of the return visit.
  final String postalCode;

  /// The [latitude] of the return visit.
  final double latitude;

  /// The [longitude] of the return visit.
  final double longitude;

  /// The [name] of the return visit.
  final String name;

  /// The [gender] of the return visit.
  final Gender gender;

  /// The [notes] regarding the return visit.
  final String notes;

  /// The [imagePath] of the return visit.
  final String imagePath;

  /// The date of the last visit.
  final int lastVisitDate;

  /// The id of the last visit.
  final int lastVisitId;

  /// A value indicating whether the return visit is [pinned].
  final bool pinned;

  const ReturnVisitDto(
      {int id = -1,
      this.name,
      this.gender,
      this.notes,
      this.imagePath,
      this.lastVisitDate,
      this.lastVisitId,
      this.pinned,
      this.street,
      this.city,
      this.state,
      this.country,
      this.postalCode,
      this.latitude,
      this.longitude})
      : super(id: id);

  @override
  ReturnVisitDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map[_columnId],
            street: map[_columnStreet],
            city: map[_columnCity],
            state: map[_columnState],
            country: map[_columnCountry],
            postalCode: map[_columnPostalCode],
            latitude: map[_columnLatitude] as num,
            longitude: map[_columnLongitude] as num,
            name: map[_columnName],
            gender: map[_columnGender] == "Male" ? Gender.Male : Gender.Female,
            notes: map[_columnNotes],
            imagePath: map[_columnImage],
            lastVisitDate: map[_columnLastVisitDate],
            lastVisitId: map[_columnLastVisitId],
            pinned: map[_columnPinned] == 1);

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) _columnId: id,
      _columnStreet: street ?? "",
      _columnCity: city ?? "",
      _columnState: state ?? "",
      _columnPostalCode: postalCode ?? "",
      _columnCountry: country ?? "",
      _columnLatitude: latitude as num,
      _columnLongitude: longitude as num,
      _columnName: name ?? "",
      _columnGender: gender.toString().split('.').last,
      _columnNotes: notes ?? "",
      _columnImage: imagePath,
      _columnLastVisitDate: lastVisitDate,
      _columnLastVisitId: lastVisitId,
      _columnPinned: pinned ? 1 : 0
    };
  }

  @override
  ReturnVisitDto copy() {
    return ReturnVisitDto.fromMap(this.toMap());
  }

  String createSearchString() {
    var s = "";
    if (name.isNotEmpty) {
      s += name;
    } else {
      s += gender.toString().split('.').last;
    }
    s += ' ' +
        "${(street != null && street.isNotEmpty) ? street + " " : ""}" +
        "${(city != null && city.isNotEmpty) ? city + ", " : ""}" +
        "${(state != null && state.isNotEmpty) ? state + " " : ""}" +
        "${(postalCode != null && postalCode.isNotEmpty) ? postalCode + " " : ""}" +
        "$country";

    return s;
  }

  ReturnVisitDto copyWith(
      {int id,
      String name,
      String street,
      String city,
      String state,
      String country,
      String postalCode,
      double latitude,
      double longitude,
      Gender gender,
      String notes,
      String imagePath,
      int lastVisitId,
      int lastVisitDate,
      bool pinned}) {
    return ReturnVisitDto(
        id: id ?? this.id,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        postalCode: postalCode ?? this.postalCode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        name: name ?? this.name,
        gender: gender ?? this.gender,
        notes: notes ?? this.notes,
        imagePath: imagePath ?? this.imagePath,
        lastVisitDate: lastVisitDate ?? this.lastVisitDate,
        lastVisitId: lastVisitId ?? this.lastVisitId,
        pinned: pinned ?? this.pinned);
  }
}

enum Gender { Male, Female }
