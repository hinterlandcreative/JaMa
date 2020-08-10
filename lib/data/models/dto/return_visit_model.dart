import 'package:jama/data/models/address_model.dart';
import 'package:jama/data/models/dto/dto.dart';

class ReturnVisitDto extends DTO {
  /// The [address] of the return visit.
  final Address address;

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
      this.address,
      this.name,
      this.gender,
      this.notes,
      this.imagePath,
      this.lastVisitDate,
      this.lastVisitId,
      this.pinned})
      : super(id: id);

  @override
  ReturnVisitDto.fromMap(Map<String, dynamic> map)
      : this(
            id: map['id'],
            address: Address.fromMap(map['address']),
            name: map['name'],
            gender: map['gender'] == "Male" ? Gender.Male : Gender.Female,
            notes: map['notes'],
            imagePath: map["imagePath"],
            lastVisitDate: map['lastVisitDate'],
            lastVisitId: map['lastVisitId'],
            pinned: map['pinned'] ?? false);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address.toMap(),
      'name': name,
      'gender': gender.toString().split('.').last,
      'notes': notes,
      'imagePath': imagePath,
      'lastVisitDate': lastVisitDate,
      'lastVisitId': lastVisitId,
      'searchString': createSearchString(),
      'pinned': pinned
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
    s += ' ' + address.toFormattedString();
    return s;
  }

  ReturnVisitDto copyWith(
      {int id,
      Address address,
      String name,
      Gender gender,
      String notes,
      String imagePath,
      int lastVisitId,
      int lastVisitDate,
      bool pinned}) {
    return ReturnVisitDto(
        id: id ?? this.id,
        address: address ?? this.address,
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
