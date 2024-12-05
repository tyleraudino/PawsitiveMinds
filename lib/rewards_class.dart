import 'dart:convert';
import 'package:http/http.dart' as http;

class Rewards {
  late String? id = null;
  late String? image_path;
  bool? unlocked;

  Rewards({this.id, required this.image_path, required this.unlocked});

  Rewards.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    image_path = json['image_path'];
    unlocked = json['unlocked'];
  }

  void completeReward() {
    unlocked = true;
  }

    // load goals from backend
  Future<List<Rewards>> getGoals(String username, String token) async {
    final String apiUrl = 'http://127.0.0.1:8000/goals/';

    try {
    
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> goalsJson = json.decode(response.body);
        
        return goalsJson.map((json) => Rewards.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load goals. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load goals: $e');
    }
  }

}
