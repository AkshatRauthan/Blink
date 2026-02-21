/// A named group of devices for recurring multi-device sharing.
class ContactGroup {
  final int? id;
  final String groupId;
  final String name;
  final List<String> memberDeviceIds;
  final DateTime? createdAt;

  const ContactGroup({
    this.id,
    required this.groupId,
    required this.name,
    this.memberDeviceIds = const [],
    this.createdAt,
  });

  ContactGroup copyWith({
    int? id,
    String? groupId,
    String? name,
    List<String>? memberDeviceIds,
    DateTime? createdAt,
  }) =>
      ContactGroup(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        name: name ?? this.name,
        memberDeviceIds: memberDeviceIds ?? this.memberDeviceIds,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'name': name,
        'memberDeviceIds': memberDeviceIds,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory ContactGroup.fromJson(Map<String, dynamic> json) => ContactGroup(
        id: json['id'] as int?,
        groupId: json['groupId'] as String,
        name: json['name'] as String,
        memberDeviceIds: (json['memberDeviceIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactGroup &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;
}
