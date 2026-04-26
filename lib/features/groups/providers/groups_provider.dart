import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/contact_group.dart';
import '../../../data/models/device.dart';
import '../../../data/repositories/groups_repository.dart';
import '../../../services/transfer/transfer_manager.dart';

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
  }) =>
      GroupsState(
        groups: groups ?? this.groups,
        isLoading: isLoading ?? this.isLoading,
      );
}

class GroupsNotifier extends Notifier<GroupsState> {
  final _repo = GroupsRepository.instance;

  @override
  GroupsState build() {
    _loadGroups();
    return const GroupsState(isLoading: true);
  }

  Future<void> _loadGroups() async {
    final groups = await _repo.allGroups();
    state = state.copyWith(groups: groups, isLoading: false);
  }

  Future<void> createGroup(String name) async {
    final group = ContactGroup(
      groupId: const Uuid().v4(),
      name: name,
      memberDeviceIds: [],
      createdAt: DateTime.now(),
    );
    await _repo.saveGroup(group);
    state = state.copyWith(groups: [group, ...state.groups]);
  }

  Future<void> deleteGroup(String groupId) async {
    await _repo.deleteGroup(groupId);
    state = state.copyWith(
      groups: state.groups.where((g) => g.groupId != groupId).toList(),
    );
  }

  Future<void> renameGroup(String groupId, String newName) async {
    final updated = state.groups.map((g) {
      if (g.groupId == groupId) return g.copyWith(name: newName);
      return g;
    }).toList();
    state = state.copyWith(groups: updated);
    final group = updated.firstWhere((g) => g.groupId == groupId);
    await _repo.updateGroup(group);
  }

  Future<void> addMember(String groupId, String deviceId) async {
    final updated = state.groups.map((g) {
      if (g.groupId == groupId && !g.memberDeviceIds.contains(deviceId)) {
        return g.copyWith(memberDeviceIds: [...g.memberDeviceIds, deviceId]);
      }
      return g;
    }).toList();
    state = state.copyWith(groups: updated);
    final group = updated.firstWhere((g) => g.groupId == groupId);
    await _repo.updateGroup(group);
  }

  Future<void> removeMember(String groupId, String deviceId) async {
    final updated = state.groups.map((g) {
      if (g.groupId == groupId) {
        return g.copyWith(
          memberDeviceIds:
              g.memberDeviceIds.where((id) => id != deviceId).toList(),
        );
      }
      return g;
    }).toList();
    state = state.copyWith(groups: updated);
    final group = updated.firstWhere((g) => g.groupId == groupId);
    await _repo.updateGroup(group);
  }

  Future<void> sendToGroup({
    required String groupId,
    required List<String> filePaths,
    required List<Device> availableDevices,
  }) async {
    final group = state.groups.firstWhere((g) => g.groupId == groupId);
    final targets = availableDevices
        .where((d) => group.memberDeviceIds.contains(d.deviceId))
        .toList();

    if (targets.isEmpty) {
      Log.w(
        'No group members online for ${group.name}',
        source: LogSource.process,
        component: 'GroupsNotifier',
      );
      return;
    }

    final files = filePaths.map((p) => File(p)).toList();

    for (final device in targets) {
      final sessionKey = Uint8List.fromList(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      try {
        await TransferManager.instance.sendFiles(
          files: files,
          remoteDeviceId: device.deviceId,
          remoteIp: device.lastKnownIp ?? '',
          remotePort: device.lastKnownPort ?? AppConstants.transferPort,
          sessionKey: sessionKey,
        );
      } catch (e) {
        Log.e(
          'Group send failed to ${device.name}: $e',
          source: LogSource.process,
          component: 'GroupsNotifier',
        );
      }
    }

    Log.i(
      'Group send: ${files.length} files to ${targets.length}/${group.memberDeviceIds.length} online members of ${group.name}',
      source: LogSource.process,
      component: 'GroupsNotifier',
    );
  }
}

final groupsNotifierProvider = NotifierProvider<GroupsNotifier, GroupsState>(
  GroupsNotifier.new,
);
