
class AddressAccess {
  String address;
  String accessor;
  String description;
  AccessType accessType;

  AddressAccess(this.address, this.accessor, this.description, this.accessType);

  factory AddressAccess.fromJson(dynamic json) {
    return AddressAccess(json['address'] as String, json['accessor'] as String,
        json['description'] as String, getAccessTypeFromString(json['accessType'] as String));
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'accessor': accessor,
    'description': description,
    'accessType': accessType.toString()
  };


  static AccessType getAccessTypeFromString(String type) {
    for (AccessType accessType in AccessType.values) {
      if (accessType.toString() == type) {
        return accessType;
      }
    }
    return null;
  }

}

enum AccessType {
  READ, WRITE

}
