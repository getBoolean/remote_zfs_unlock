import 'package:hive_ce/hive.dart';
import 'package:remote_zfs_unlock/models/server_profile.dart';

class ServerRepository {
  ServerRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  Future<List<ServerProfile>> readAll() async {
    final entries = _box.values
        .map(
          (value) =>
              ServerProfileMapper.fromMap(Map<String, dynamic>.from(value)),
        )
        .toList();
    entries.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return entries;
  }

  Future<void> upsert(ServerProfile profile) async {
    await _box.put(profile.id, profile.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
