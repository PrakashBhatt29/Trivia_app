// Author: Daniel McErlean
// Title: Prompt Page
// About: Prompts users for username, number of questions, category and difficulty of questions.
//        Information is then sent through with the API call, in which data recieved is then stored in data_provider,
//        username is sent directly to the game_page where it will be registered when the game is over in data_provider

import 'dart:convert';

import '../providers/data_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool finishedLoading = false;

List<String> categoryList = ["Any Category"];
List<String> categoryIdList = ["0"];

String SEARCH_EP = "https://opentdb.com/api.php?";

class PromptPage extends StatefulWidget {
  const PromptPage({super.key});

  @override
  State<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  List<String> difficultyList = [
    "Any Difficulty",
    "Easy",
    "Medium",
    "Hard",
  ];
  String? difficultySelected = "Any Difficulty";
  String? categorySelected = "Any Category";

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _questionsController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _questionsFocusNode = FocusNode();

  // Shared Preferences
  late SharedPreferences prefs;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      String? username = prefs.getString("username");
      String? questions = prefs.getString("questions");
      String? category = prefs.getString("category");
      String? diffculty = prefs.getString("difficulty");

      if (username != null) {
        _usernameController.text = username;
      }
      if (questions != null) {
        _questionsController.text = questions;
      }
      if (category != null) {
        categorySelected = category;
      }
      if (diffculty != null) {
        difficultySelected = diffculty;
      }
    });
  }

  // save form data to shared_preferences
  Future saveData() async {
    await prefs.setString("username", _usernameController.text);
    await prefs.setString("questions", _questionsController.text);
    await prefs.setString("category", categorySelected!);
    await prefs.setString("difficulty", difficultySelected!);
  }

  @override
  void initState() {
    super.initState();

    // create category list only once since data persists after page is popped
    if (categoryList.length < 2) {
      createCategoryList();
    }
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        usernameInput(context),
                        numQuestions(),
                        finishedLoading
                            ? categoryDropdown()
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                        difficultyDropdown(),
                        Expanded(child: Container()),
                        startButton(context),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

// Form for entering username
  Widget usernameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: _usernameController,
        focusNode: _usernameFocusNode,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a username';
          }
          return null;
        },
        onEditingComplete: () {
          saveData();
          FocusScope.of(context).requestFocus(_questionsFocusNode);
        },
        style: Theme.of(context).textTheme.titleSmall,
        decoration: InputDecoration(
          label: const Text("Username"),
          fillColor: Colors.white,
          filled: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
            borderSide: BorderSide(width: 2),
          ),
          contentPadding: const EdgeInsets.all(8),
          suffixIcon: IconButton(
            onPressed: () async {
              await prefs.remove('username');
              _usernameController.clear();
            },
            icon: const Icon(Icons.clear),
          ),
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

// Form for entering numQuestions
  Widget numQuestions() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: _questionsController,
        focusNode: _questionsFocusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        maxLength: 2,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter a number';
          } else if (int.tryParse(value) == null ||
              int.parse(value) > 50 ||
              int.parse(value) < 1) {
            return 'Enter a number between 1 and 50';
          }
          return null;
        },
        onEditingComplete: () {
          saveData();
          _questionsFocusNode.unfocus();
        },
        style: Theme.of(context).textTheme.titleSmall,
        decoration: InputDecoration(
          label: const Text("# of Questions (Max 50)"),
          fillColor: const Color.fromARGB(255, 235, 175, 175),
          filled: true,
          counterText: "",
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
            borderSide: BorderSide(width: 2),
          ),
          contentPadding: const EdgeInsets.all(8),
          suffixIcon: IconButton(
            onPressed: () async {
              await prefs.remove('questions');
              _questionsController.clear();
            },
            icon: const Icon(Icons.clear),
          ),
        ),
      ),
    );
  }

// Dropdown list for picking category
  Widget categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField(
        isExpanded: true,
        value: categorySelected,
        items: categoryList.map((String option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(
            () {
              categorySelected = value;
              saveData();
            },
          );
        },
        style: Theme.of(context).textTheme.titleSmall,
        decoration: const InputDecoration(
          label: Text("Category"),
          fillColor: Color.fromARGB(255, 224, 186, 186),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
            borderSide: BorderSide(width: 2),
          ),
          contentPadding: EdgeInsets.all(8),
        ),
      ),
    );
  }

// Dropdown list for picking difficulty
  Widget difficultyDropdown() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField(
        isExpanded: true,
        value: difficultySelected,
        items: difficultyList.map((String option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(
            () {
              difficultySelected = value;
              saveData();
            },
          );
        },
        style: Theme.of(context).textTheme.titleSmall,
        decoration: const InputDecoration(
          label: Text("Difficulty"),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
            borderSide: BorderSide(width: 2),
          ),
          contentPadding: EdgeInsets.all(8),
        ),
      ),
    );
  }

// Start Game
  Widget startButton(BuildContext context) {
    var dataProvider = context.watch<DataProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 40),
      child: ElevatedButton(
        onPressed: () async {
          // If entries are valid in formFields
          if (_formKey.currentState!.validate()) {
            ///// Get values from form fields and dropdowns /////
            var username = _usernameController.text;
            var numQuestions = _questionsController.text;

            // url doesnt take strings, so map it to the specific id
            if (!categoryList.contains(categorySelected!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check your internet and select a category!'),
                ),
              );
              return;
            }
            var categoryId =
                categoryIdList[categoryList.indexOf(categorySelected!)];

            String difficulty;
            // url doesnt take "any diffculty" as a string, so change it to 0
            if (difficultySelected == 'Any Difficulty') {
              difficulty = "0";
            } else {
              difficulty = difficultySelected!.toLowerCase();
            }

            ///// Create new url with values /////
            var url =
                '${SEARCH_EP}amount=$numQuestions&category=$categoryId&difficulty=$difficulty';

            ///// pass url into search function /////
            var data = await search(url);

            // fixes 'dont use build context across async code'
            if (!context.mounted) return;

            if (data == null) {
              return;
            }

            // return if API fetch came back with no results (will happen if there's not enough questions)
            if (data['response_code'] == 1) {
              // tell user how many questions are available
              var url =
                  'https://opentdb.com/api_count.php?category=$categoryId';

              var data = await search(url);

              // fixes 'dont use build context across async code'
              if (!context.mounted) return;

              // show different message depending on difficulty selected
              // if not enough questions in request
              switch (difficulty) {
                case '0':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'There are only ${data['category_question_count']['total_question_count']} questions in this category!'),
                    ),
                  );
                  break;
                case 'easy':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "There are only ${data['category_question_count']['total_easy_question_count']} questions in this category's difficulty!"),
                    ),
                  );
                  break;
                case 'medium':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "There are only ${data['category_question_count']['total_medium_question_count']} questions in this category's difficulty!"),
                    ),
                  );
                  break;
                case 'hard':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "There are only ${data['category_question_count']['total_hard_question_count']} questions in this category's difficulty!"),
                    ),
                  );
                  break;
              }

              return;
            }

            // save preferences
            saveData();

            ///// send returned json to game_page/data_provider /////
            dataProvider.changetriviaResponse(data);

            // send user to game page
            Navigator.pushReplacementNamed(
              context,
              "/game",
              arguments: {'username': username},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fix issues and try again!'),
              ),
            );
          }
        },
        child: const Text("Start"),
      ),
    );
  }

// Sets up Dropdown list for categories
  Future createCategoryList() async {
    try {
      var json = await search("https://opentdb.com/api_category.php");

      json["trivia_categories"].forEach((item) {
        setState(() {
          categoryList.add(item["name"]);
          categoryIdList.add(item["id"].toString());
        });
      });

      setState(() {
        finishedLoading = true;
      });
    } catch (e) {
      return;
    }
  }

// Searches API urls and returns json
  Future search(String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data, ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check you internet connection!'),
        ),
      );
    }
  }
}
