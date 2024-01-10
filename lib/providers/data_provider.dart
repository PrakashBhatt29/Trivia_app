

import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class DataProvider with ChangeNotifier {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // List<String> _users = [];
  var _users = [];

  var _questions = [];

  // get score => (username) async {
  //       final SharedPreferences prefs = await _prefs;
  //       final int score = prefs.getInt(username) ?? 0;
  //       return score;
  //     };

  get users => _users;
  get questions => _questions;

  void changetriviaResponse(var triviaResponse) {
    // ensures _questions is empty each game round
    var temp = [];
    triviaResponse['results'].forEach((item) {
      temp.add(item);
    });
    _questions = temp;
    notifyListeners();
  }

  void addUser(username) {
    // // check if name list exists in shared_preferences
    // final SharedPreferences prefs = await _prefs;
    // final List<String> users = prefs.getStringList('users') ?? [];

    // // if exists, get and set equal to temp list
    // List<String> temp = users;

    // // add user to temp list
    // temp.add(username);

    // // add temp list to user list and store
    // _users = await prefs.setStringList('users', temp).then((bool success) {
    //   return temp;
    // });

    // New Code not using shared_preferences
    for (var map in _users) {
      if (map['name'] == username) {
        return;
      }
    }
    _users.add({"name": username, "score": 0});
  }

  void updateHighscore(String username, int score) async {
    // // get name list from shared_preferences
    // final SharedPreferences prefs = await _prefs;
    // final List<String>? users = prefs.getStringList('users');
    // int tempScore = 0;

    // // check if name key matches current name
    // if (users!.contains(username)) {
    //   // if matches, get score
    //   tempScore = prefs.getInt(username) ?? 0;
    // }

    // // add current score to user score and store
    // tempScore += score;
    // prefs.setInt(username, tempScore);

    // New Code not using shared_preferences
    for (var map in _users) {
      if (map['name'] == username) {
        map['score'] += score;
      }
    }

    _users.sort((a, b) => b['score'].compareTo(a['score']));
  }
}
