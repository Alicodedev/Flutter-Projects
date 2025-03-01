import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'styles.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      routes: {
        '/': (context) => HomeRoute(),
        '/second': (context) => SecondRoute(),
      },
      initialRoute: '/',
    ),
  );
}

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() => _HomeRouteState();



}


class _HomeRouteState extends State<HomeRoute> {
  final _formKey = GlobalKey<FormState>();
  final _teamName = TextEditingController();
  final _teamCity = TextEditingController();
  final _teamCountry = TextEditingController();
  late List<TextEditingController> playerControllers;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    playerControllers = List.generate(5, (index) => TextEditingController());
  }

  bool _validateFields() {
    if (_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
            'Futsal builder app',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),

        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Information fields
                TextFormField(
                  controller: _teamName,
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter team name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _teamCity,
                  decoration: InputDecoration(
                    labelText: 'Team City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Please enter team city';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _teamCountry,
                  decoration: InputDecoration(
                    labelText: 'Team Country',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Please enter team country';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Player fields
                ...List.generate(
                  5,
                      (index) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: playerControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Player ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                          return 'Please enter player ${index + 1} name';
                        }

                        return null;
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Submit button
                Center(
                  child: ElevatedButton(
                    style: AppStyles.customButtonStyle,
                    child: Text(
                      'Create Team',
                      style: AppStyles.buttonTextStyle,
                    ),
                    onPressed: () {
                      if (_validateFields()) {
                        _showSnackBar('Validating team information');
                        // Create team object
                        final team = TeamBuilder(
                          teamName: _teamName.text,
                          teamCity: _teamCity.text,
                          teamCountry: _teamCountry.text,
                          players: playerControllers.map((c) => c.text).toList(),
                        );

                        // Show success alert
                        Alert(
                          context: context,
                          type: AlertType.success,
                          title: "Success",
                          desc: "Team created successfully",
                          buttons: [
                            DialogButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.pop(context); // Close alert
                                Navigator.pushNamed(
                                  context,
                                  '/second',
                                  arguments: {
                                    'teamName': _teamName.text,
                                    'players': playerControllers.map((c) =>
                                    c.text).toList(),
                                  },
                                );
                              },
                            )
                          ],
                        ).show();
                        } else {
                        _showSnackBar('Invalid team information.');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _teamName.dispose();
    _teamCity.dispose();
    _teamCountry.dispose();
    for (var controller in playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}



class SecondRoute extends StatefulWidget {  // Changed to StatefulWidget
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  // Score tracking
  Map<String, int> scores = {};
  Map<String, int> corners = {};
  late String teamName; // Add this

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    // Initialize scores for both teams to avoid null checks
    scores = {
      'Opposition': 0,
    };
    corners = {
      'Opposition': 0,
    };
  }

  void _updateScore(String team, int value) {
    setState(() {
      scores[team] = (scores[team] ?? 0) + value;
    });
  }

  void _updateCorners(String team, int value) {
    setState(() {
      corners[team] = (corners[team] ?? 0) + value;
    });
  }

  String _determineWinner() {
    int teamScore = scores[teamName] ?? 0;
    int oppositionScore = scores['Opposition'] ?? 0;

    if (teamScore == 0 && oppositionScore == 0) {
      return "Game ended with no goals";
    } else if (teamScore > oppositionScore) {
      return "$teamName wins with $teamScore goals!";
    } else if (oppositionScore > teamScore) {
      return "Opposition wins with $oppositionScore goals!";
    } else {
      return "It's a tie with $teamScore goals each!";
    }
  }

  @override
  Widget build(BuildContext context) {

    //final ScreenArguments? args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    teamName = args?['teamName'] as String? ?? 'Team'; // Assign to class field
    final players = args?['players'] as List<String>? ?? [];

    if (!scores.containsKey(teamName)) {
      scores[teamName] = 0;
      corners[teamName] = 0;
    }

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(child: Text('No team data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Match Stats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Team Stats Container
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Score Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '${scores[teamName] ?? 0}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${scores['Opposition'] ?? 0}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Team Names
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              teamName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Opposition',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Score Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                ElevatedButton(
                                  style: AppStyles.customButtonStyle,
                                  onPressed: () => _updateScore(teamName, 1),
                                  child: Text('Add Goal'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  style: AppStyles.customButtonStyle,
                                  onPressed: () => _updateCorners(teamName, 1),
                                  child: Text('Add Corner'),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  style: AppStyles.customButtonStyle,
                                  onPressed: () => _updateScore('Opposition', 1),
                                  child: Text('Add Goal'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  style: AppStyles.customButtonStyle,
                                  onPressed: () => _updateCorners('Opposition', 1),
                                  child: Text('Add Corner'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Corners Display
                  Text(
                    'Corners',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '${corners[teamName] ?? 0}',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        '${corners['Opposition'] ?? 0}',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: AppStyles.customButtonStyle,
                  onPressed: () {
                    // Get the result before clearing scores
                    String result = _determineWinner();

                    // Show the result
                    _showSnackBar(context, result);

                    // Clear scores after a delay to ensure the correct result is shown
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        // Reset scores to 0 instead of clearing them
                        scores = {
                          teamName: 0,
                          'Opposition': 0,
                        };
                        corners = {
                          teamName: 0,
                          'Opposition': 0,
                        };
                      });
                    });
                  },
                  child: Text('End Game'),
                ),
                ElevatedButton(
                  style: AppStyles.customButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back to Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String message;
  final String teamName;
  ScreenArguments(this.title, this.message, this.teamName);
}

class TeamBuilder {
  final String teamName;
  final String teamCity;
  final String teamCountry;
  final List<String> players;

  TeamBuilder({
    required this.teamName,
    required this.teamCity,
    required this.teamCountry,
    required this.players,
  });
}