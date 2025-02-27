import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
        title: Text(
            'FC builder app',
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
                    child: Text('Create Team'),
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
                                  arguments: ScreenArguments(
                                    'Team Created',
                                    'Team ${_teamName.text} has been created!',
                                  ),
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

class SecondRoute extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ScreenArguments? args = ModalRoute.of(context)?.settings.arguments as ScreenArguments?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: Center(
          child: Text('No arguments provided.'),
        ),
      );
    }

    // Show welcome SnackBar when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSnackBar(context, 'Welcome to your new team page');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              args.message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSnackBar(context, 'Returning to Home page');
                Future.delayed(
                  Duration(seconds: 1),
                      () => Navigator.pop(context),
                );
              },
              child: Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String message;
  ScreenArguments(this.title, this.message);
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