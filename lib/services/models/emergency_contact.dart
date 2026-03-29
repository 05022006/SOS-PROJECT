class EmergencyContact {
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final bool isPrimary;
  final String? relationship;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.isPrimary = false,
    this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'isPrimary': isPrimary,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      isPrimary: map['isPrimary'] ?? false,
      relationship: map['relationship'],
    );
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    bool? isPrimary,
    String? relationship,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
      relationship: relationship ?? this.relationship,
    );
  }
}
