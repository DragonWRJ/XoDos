import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String boxName = 'messages_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future<void> saveMessage({
    required String id,
    required String text,
    required bool isMe,
    required String timestamp,
  }) async {
    final box = Hive.box(boxName);
    await box.put(id, {
      'id': id,
      'text': text,
      'isMe': isMe,
      'timestamp': timestamp,
      'isDeletedBySender': false,
    });
  }

  static Future<void> markAsDeletedBySender(String id) async {
    final box = Hive.box(boxName);
    final msg = box.get(id);
    if (msg != null) {
      msg['isDeletedBySender'] = true;
      await box.put(id, msg);
    }
  }

  static List<Map<dynamic, dynamic>> getMessages() {
    final box = Hive.box(boxName);
    return box.values.cast<Map<dynamic, dynamic>>().toList();
  }
}
