import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A contact group for quick multi-device transfers.
class ContactGroup {
  final String id;
  final String name;
  final List<String> memberDeviceIds;
  final DateTime createdAt;

  const ContactGroup({
    required this.id,
    required this.name,
    required this.memberDeviceIds,
    required this.createdAt,
  });

  ContactGroup copyWith({
    String? name,
    List<String>? memberDeviceIds,
  }) {
    return ContactGroup(
      id: id,
      name: name ?? this.name,
      memberDeviceIds: memberDeviceIds ?? this.memberDeviceIds,
      createdAt: createdAt,
    );
  }
}

/// State for the groups feature.
class GroupsState {
  final List<ContactGroup> groups;
  final bool isLoading;

  const GroupsState({
    this.groups = const [],
    this.isLoading = false,
  });

  GroupsState copyWith({
    List<ContactGroup>? groups,
    bool? isLoading,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for managing contact groups.
class GroupsNotifier extends Notifier<GroupsState> {
  @override
  GroupsState build() {
    // Return some demo data
    return GroupsState(
      groups: [
        ContactGroup(
          id: '1',
          name: 'Family',
          memberDeviceIds: ['device1', 'device2', 'device3', 'device4'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ContactGroup(
          id: '2',
          name: 'Work Team',
          memberDeviceIds: ['device5', 'device6', 'device7'],
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        ContactGroup(
          id: '3',
          name: 'Friends',
          memberDeviceIds: ['device8', 'device9'],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );
  }

  void createGroup(String name) {
    final group = ContactGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      memberDeviceIds: [],
      createdAt: DateTime.now(),
    );
    state = state.copyWith(groups: [...state.groups, group]);
  }

  void deleteGroup(String groupId) {
    state = state.copyWith(
      groups: state.groups.where((g) => g.id != groupId).toList(),
    );
  }

  void renameGroup(String groupId, String newName) {
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id == groupId) {
          return g.copyWith(name: newName);
        }
        return g;
      }).toList(),
    );
  }

  void addMember(String groupId, String deviceId) {
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id == groupId && !g.memberDeviceIds.contains(deviceId)) {
          return g.copyWith(memberDeviceIds: [...g.memberDeviceIds, deviceId]);
        }
        return g;
      }).toList(),
    );
  }

  void removeMember(String groupId, String deviceId) {
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id == groupId) {
          return g.copyWith(
            memberDeviceIds: g.memberDeviceIds.where((id) => id != deviceId).toList(),
          );
        }
        return g;
      }).toList(),
    );
  }
}

final groupsNotifierProvider = NotifierProvider<GroupsNotifier, GroupsState>(
  GroupsNotifier.new,
);
