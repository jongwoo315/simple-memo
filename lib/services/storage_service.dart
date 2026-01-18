import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memo.dart';

class StorageService {
  static const String _key = 'memos';

  Future<List<Memo>> loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Memo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveMemos(List<Memo> memos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = memos.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
}
