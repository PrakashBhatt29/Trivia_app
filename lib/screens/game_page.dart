// Author: Daniel McErlean
// Title: Game Page
// About: Main game page for prompting the user with trivia questions, answers, and submitting their selection.
//       
 
import '../providers/data_provider.dart';

import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool gameOver = false;
bool submitted = false;
bool disabled = false;
String result = '';
List<Text> options = <Text>[];
var submitColor = const Color.fromARGB(255, 188, 138, 248);
var index = 0;
var score = 0;

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<bool> _selectedOptions = <bool>[false, false, false, false];
  List<bool> _selectedOptionsBool = <bool>[false, false];
  bool shuffled = false;

  @override
  Widget build(BuildContext context) {
    // Gets argument data from prompt_page (username)
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    // Gets questions data from data_provider
    var questions = context.read<DataProvider>().questions;

    // key for scrolling back to top
    var scrollKey = GlobalKey();

    return WillPopScope(
      // When user hits back button, this is called to prevent variables from persisting
      onWillPop: () {
        // Ask if user is sure they want to quit mid-game (only if gameOver is false)
        if (!gameOver) {
          return backButtonPressed(context);
        }

        // else, quit game and still reset variables
        gameOver = false;
        shuffled = false;
        submitted = false;
        submitColor = const Color.fromARGB(255, 188, 138, 248);
        disabled = false;
        index = 0;
        score = 0;
        options = <Text>[];

        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: gameOver
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                backgroundColor: changeColor(questions),
                title: Text(
                  "${questions[index]['category']}",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 13,
                  ),
                ),
                toolbarHeight: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width / 8 : kToolbarHeight,
              ),
        body: DecoratedBox(
          decoration: BoxDecoration(
              image: gameOver
                  ? const DecorationImage(
                      image: AssetImage('assets/images/Background22.jpg'),
                      fit: BoxFit.fill,
                    )
                  : null),
          child: Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    // only display gameOverView when game is over, otherwise display Column and main game
                    child: gameOver
                        ? gameOverView(questions)
                        : Column(
                            children: [
                              Padding(
                                key: scrollKey,
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  "Question ${index + 1} of ${questions.length}",
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                              displayQuestion(questions),
                              displayAnswers(questions),
                              submitted
                                  // Show the answer only if the user pressed 'submit'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        '${result}The answer was:\n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : const Text(''),
                              submitted
                                  // Show the answer only if the user pressed 'submit'
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 35.0),
                                      child: Text(
                                        parseFragment(questions[index]
                                                ['correct_answer'])
                                            .text!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : const Text(''),
                              submitted
                                  // Show next question button if user pressed 'submit', otherwise show submit button
                                  ? nextQuestion(
                                      context, questions, arguments, scrollKey)
                                  : submitAnswer(context, questions),
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

  // function for reseting variables after each question is answered
  void resetState() {
    shuffled = false;
    submitted = false;
    submitColor = const Color.fromARGB(255, 188, 138, 248);
    disabled = false;
    options = <Text>[];
    _selectedOptions = <bool>[false, false, false, false];
    _selectedOptionsBool = <bool>[false, false];
  }

  // appbar color changes depending on difficulty of question
  Color? changeColor(questions) {
    if (questions[index]['difficulty'] == 'easy') {
      return Colors.green;
    } else if (questions[index]['difficulty'] == 'medium') {
      return const Color.fromARGB(255, 209, 191, 27);
    } else if (questions[index]['difficulty'] == 'hard') {
      return Colors.red;
    }
    return null;
  }

  // Game Over View, displayed when all questions are exhausted
  Widget gameOverView(questions) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 4,
        ),
        Text(
          "Game Over",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        // display username and score
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "You got $score of ${questions.length} questions correct!",
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(child: Container()),
        // ask to play again, or go home
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: ElevatedButton(
            onPressed: () {
              gameOver = false;
              score = 0;
              Navigator.popAndPushNamed(context, "/prompt");
            },
            child: const Text("Play Again"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: ElevatedButton(
            onPressed: () {
              gameOver = false;
              score = 0;
              Navigator.popAndPushNamed(context, "/");
            },
            child: const Text("Go Home"),
          ),
        ),
      ],
    );
  }

  // Displays each question in questions list
  Widget displayQuestion(questions) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        // parseFragment fixes html encoded responses
        parseFragment(questions[index]['question']).text!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  // Displays each answer option in questions list
  Widget displayAnswers(questions) {
    // send different data to returnAnswers() depending on question type
    if (questions[index]['type'] == 'multiple') {
      List<Text> optionsUnshuffled = <Text>[
        Text(parseFragment(questions[index]['correct_answer']).text!),
        Text(parseFragment(questions[index]['incorrect_answers'][0]).text!),
        Text(parseFragment(questions[index]['incorrect_answers'][1]).text!),
        Text(parseFragment(questions[index]['incorrect_answers'][2]).text!),
      ];
      double minHeight = 70;
      return returnAnswers(optionsUnshuffled, _selectedOptions, minHeight);
    } else {
      List<Text> optionsUnshuffled = <Text>[
        Text(parseFragment(questions[index]['correct_answer']).text!),
        Text(parseFragment(questions[index]['incorrect_answers'][0]).text!),
      ];
      double minHeight = 100;
      return returnAnswers(optionsUnshuffled, _selectedOptionsBool, minHeight);
    }
  }

  // Submit button for choosing an answer
  Widget submitAnswer(BuildContext context, questions) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ElevatedButton(
            onPressed: () {
              // send different data to showAnswer() depending on question type
              if (questions[index]['type'] == 'multiple') {
                showAnswer(_selectedOptions, questions);
              } else {
                showAnswer(_selectedOptionsBool, questions);
              }
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
              elevation: 10,
              minimumSize: Size(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 9,
              ),
            ),
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }

  // displays some info before next question
  Widget nextQuestion(BuildContext context, questions, arguments, scrollKey) {
    var dataProvider = context.watch<DataProvider>();

    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ElevatedButton(
            onPressed: () async {
              // reset variables each question
              resetState();

              // if there are still more questions left, increase questions' index
              if (index < questions.length - 1) {
                setState(() {
                  index++;
                });

                Scrollable.ensureVisible(scrollKey.currentContext!);
              }
              // No questions are left, end the game and display the gameOverView by setting gameOver to true
              else {
                questions = [];
                index = 0;
                dataProvider.addUser(arguments['username']);
                dataProvider.updateHighscore(arguments['username'], score);
                setState(() {
                  gameOver = true;
                });
                //Navigator.popAndPushNamed(context, "/prompt");
              }
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
              elevation: 10,
              minimumSize: Size(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 9,
              ),
            ),
            child: const Text("Next"),
          ),
        ),
      ),
    );
  }

  // returnAnswers() used since there are slight differences with different type questions
  // called from displayAnswers()
  returnAnswers(
      List<Text> optionsUnshuffled, List<bool> selectedOptions, double height) {
    // only shuffle the list once per question
    if (!shuffled) {
      optionsUnshuffled.shuffle();
      options = optionsUnshuffled;
      shuffled = true;
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: ToggleButtons(
            textStyle: Theme.of(context).textTheme.titleMedium,
            direction: Axis.vertical,
            onPressed: (int index) {
              setState(() {
                // tapped button set to true, others set to false
                for (int i = 0; i < selectedOptions.length; i++) {
                  selectedOptions[i] = i == index;
                }
              });
            },
            splashColor: const Color.fromARGB(255, 182, 122, 255),
            selectedColor: Colors.black,
            borderColor: Colors.black,
            selectedBorderColor: Colors.black,
            fillColor: submitColor,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height < 1000 ? height : height * 1.85,
              minWidth: MediaQuery.of(context).size.width / 1.3,
              maxWidth: MediaQuery.of(context).size.width / 1.3,
            ),
            isSelected: selectedOptions,
            children: options,
          ),
        ),
      ),
    );
  }

  // showAnswer() used for slight differences in checking against answers
  // called from submitAnswer()
  showAnswer(optionsType, questions) {
    // if nothing is selected, return
    if (optionsType.indexOf(true) == -1) {
      return;
    }

    // Submission was Correct
    else if (parseFragment(questions[index]['correct_answer']).text! ==
        options[optionsType.indexOf(true)].data && !submitted) {
      // change selected color (submitColor),
      // disable changing the selected options (disabled),
      // changes this button to the nextQuestion button (submitted)
      setState(() {
        submitColor = const Color(0xFF5BB450);
        disabled = true;
        submitted = true;
        result = 'Correct! ';
        score++;
      });
    }
    // Submission was Wrong
    else if (!submitted) {
      setState(() {
        submitColor = const Color(0xFFF94449);
        disabled = true;
        submitted = true;
        result = 'Wrong. ';
      });
    }
  }

// called when user presses back button
  backButtonPressed(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Are you sure you want to quit? All progess will be lost.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                      Size(
                        MediaQuery.of(context).size.width / 5,
                        MediaQuery.of(context).size.height / 20,
                      ),
                    ),
                  ),
                  child: const Text("No"),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameOver = false;
                    shuffled = false;
                    submitted = false;
                    submitColor = const Color.fromARGB(255, 188, 138, 248);
                    disabled = false;
                    //questions = [];
                    index = 0;
                    score = 0;
                    options = <Text>[];

                    // pop both showDialogue and game screen
                    Navigator.of(context).pop();
                    Navigator.pop(context, false);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                      Size(
                        MediaQuery.of(context).size.width / 5,
                        MediaQuery.of(context).size.height / 20,
                      ),
                    ),
                  ),
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
