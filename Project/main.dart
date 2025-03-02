import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isGameInProgress = false;

  Future<void> saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teamName', _teamName.text);
    await prefs.setString('teamCity', _teamCity.text);
    await prefs.setString('teamCountry', _teamCountry.text);

    // Save player names
    for (int i = 0; i < playerControllers.length; i++) {
      await prefs.setString('player_$i', playerControllers[i].text);
    }

    await prefs.setBool('gameInProgress', true);
  }

  Future<void> loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teamName.text = prefs.getString('teamName') ?? '';
      _teamCity.text = prefs.getString('teamCity') ?? '';
      _teamCountry.text = prefs.getString('teamCountry') ?? '';

      // Load player names
      for (int i = 0; i < playerControllers.length; i++) {
        playerControllers[i].text = prefs.getString('player_$i') ?? '';
      }

      isGameInProgress = prefs.getBool('gameInProgress') ?? false;
    });
  }

  Future<void> clearGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _teamName.clear();
      _teamCity.clear();
      _teamCountry.clear();
      for (var controller in playerControllers) {
        controller.clear();
      }
      isGameInProgress = false;
    });
  }

  void showResumeGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resume Game'),
          content: Text('Would you like to resume the previous game or start a new one?'),
          actions: [
            TextButton(
              child: Text('New Game'),
              onPressed: () {
                clearGameData();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Resume'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/second',
                  arguments: {
                    'teamName': _teamName.text,
                    'players': playerControllers.map((c) => c.text).toList(),
                    'resuming': true,
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }




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
    loadGameData(); // Load saved data when app starts
  }

  bool _validateFields() {
    if (_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Check for existing game
    if (isGameInProgress && _teamName.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showResumeGameDialog();
      });
    }

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
                // Replace this entire Center widget and its contents
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
                                saveGameData(); // Save the game data
                                Navigator.pushNamed(
                                  context,
                                  '/second',
                                  arguments: {
                                    'teamName': _teamName.text,
                                    'players': playerControllers.map((c) => c.text).toList(),
                                    'resuming': false,
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

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  Map<String, int> scores = {};
  Map<String, int> corners = {};
  late String teamName;

  Future<void> saveGameScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${teamName}_score', scores[teamName] ?? 0);
    await prefs.setInt('opposition_score', scores['Opposition'] ?? 0);
    await prefs.setInt('${teamName}_corners', corners[teamName] ?? 0);
    await prefs.setInt('opposition_corners', corners['Opposition'] ?? 0);
  }

  Future<void> loadGameScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scores = {
        teamName: prefs.getInt('${teamName}_score') ?? 0,
        'Opposition': prefs.getInt('opposition_score') ?? 0,
      };
      corners = {
        teamName: prefs.getInt('${teamName}_corners') ?? 0,
        'Opposition': prefs.getInt('opposition_corners') ?? 0,
      };
    });
  }

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
    scores = {'Opposition': 0};
    corners = {'Opposition': 0};
  }

  void _updateScore(String team, int value) {
    setState(() {
      scores[team] = (scores[team] ?? 0) + value;
    });
    saveGameScores();
  }

  void _updateCorners(String team, int value) {
    setState(() {
      corners[team] = (corners[team] ?? 0) + value;
    });
    saveGameScores();
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    teamName = args?['teamName'] as String? ?? 'Team';
    final players = args?['players'] as List<String>? ?? [];
    final isResuming = args?['resuming'] as bool? ?? false;

    if (isResuming) {
      loadGameScores();
    }

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
                  onPressed: () async {
                    String result = _determineWinner();
                    _showSnackBar(context, result);

                    // Clear game progress
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('gameInProgress', false);

                    setState(() {
                      scores = {teamName: 0, 'Opposition': 0};
                      corners = {teamName: 0, 'Opposition': 0};
                    });
                    saveGameScores();
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