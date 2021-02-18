
class AddressOwner {
  String address;
  String owner;
  String label;
  String description;

  AddressOwner(this.address, this.owner, this.label, this.description);

  factory AddressOwner.fromJson(dynamic json) {
    return AddressOwner(json['address'] as String, json['owner'] as String,
        json['label'] as String, json['description'] as String);
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'owner': owner,
    'label': label,
    'description': description
  };
}
