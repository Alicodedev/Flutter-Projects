import 'package:fl_chart/fl_chart.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          )
        )
      ),
      routes: {
        '/': (context) => Home(),
        '/bar': (context) => SimpleBarChart(),
        '/line': (context) => SimpleLineChart(),
      },
      initialRoute: '/',
    );
  }
}


class StudentData {
  static List<Student> students = [];

  static void generateStudents() {
    students.clear();
    for (var i = 0; i < 10; i++) {
      var student = Student.random(i + 1);
      students.add(student);
    }
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bar');
              },
              child: const Text('Bar Chart'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/line');
              },
              child: const Text('Line Chart'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                StudentData.generateStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${StudentData.students.length} Students Generated')),
                );
              },
              child: const Text('Generate Random Students'),
            ),
          ],
        ),
      ),
    );
  }
}

// *** BAR CHART ROUTE
class SimpleBarChart extends StatefulWidget {
  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  late List<BarChartGroupData> dataList = [];

  // initialize data
  @override
  void initState() {
    super.initState();
    generateChartData();
  }

  // generate the dataList for the bar chart
  generateChartData() {
    dataList.clear(); // Clear previous data
    for (int i = 0; i < StudentData.students.length; i++) {
      Student student = StudentData.students[i];

      // dtermine color based on student status
      BarChartGroupData barChartGroupData = BarChartGroupData(x: i,
        barRods: [
          BarChartRodData(toY: student.mobile.toDouble(), color: Colors.red),
          BarChartRodData(toY: student.web.toDouble(), color: Colors.blue),
        ],
      );
      dataList.add(barChartGroupData);
    }
  }


  Widget getTitles(double value, TitleMeta meta) {
    return Text(
      StudentData.students[value.toInt()].name,
      style: TextStyle(color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bar Chart')),
      body: Center(
        child: Container(
          width: 800,
          height: 900,
          padding: EdgeInsets.all(16),
          child: StudentData.students.isNotEmpty
            ? BarChart(
                BarChartData(
                  barGroups: dataList,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: false,
                    )),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: getTitles,
                      ),
                    ),
                  ),
                ),
                duration: Duration(milliseconds: 150),
                curve: Curves.linear,
              )
            : Text('Generate Students First'),
        ),
      ),
    );
  }
}
// *** END BAR CHART ROUTE


// *** LINE CHART ROUTE
class SimpleLineChart extends StatefulWidget {
  @override
  _LineChartState createState() => _LineChartState();


}
class _LineChartState extends State<SimpleLineChart> {
  late List<LineChartBarData> dataList = [];

  @override
  void initState() {
    super.initState();
    generateChartData();
  }

  generateChartData() {
    dataList.clear(); // Clear previous data

    // line data for mobile scores
    var mobileScores = LineChartBarData(
      isCurved: true,
      color: Colors.red,
      barWidth: 2,
      spots: StudentData.students.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.mobile.toDouble());
      }).toList(),
    );

    // line data for web scores
    var webScores = LineChartBarData(
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      spots: StudentData.students.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.web.toDouble());
      }).toList(),
    );

    dataList = [mobileScores, webScores];
  }

  Widget getTitles(double value, TitleMeta meta) {
    return Text(
      StudentData.students[value.toInt()].name,
      style: TextStyle(color: Colors.blue)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Line Chart')),
      body: Center(
        child: Container(
          width: 800,
          height: 900,
          padding: EdgeInsets.all(16),
          child: StudentData.students.isNotEmpty
            ? LineChart(
                LineChartData(
                  lineBarsData: dataList,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getTitles,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              )
            : Text('Generate Students First'),
        ),
      ),
    );
  }
}// *** END LINE CHART ROUTE

class Student {
  static int count = 0;
  late String name;
  late int studentID;
  late int mobile;
  late int web;
  late int programming;
  late int embedded;

  // Default Constructor
  Student(String n, int id, int m, int w, int p, int e) {
    count++;
    name = n;
    studentID = id;
    mobile = m;
    web = w;
    programming = p;
    embedded = e;
  }

  // Method to find minimum grade without conditions
  int minGrade() {
    return [mobile, web, programming, embedded].reduce((a, b) => a < b ? a : b);
  }

  // Method to find maximum grade without conditions
  int maxGrade() {
    return [mobile, web, programming, embedded].reduce((a, b) => a > b ? a : b);
  }

  // Method to calculate average grade
  double averageGrade() {
    return (mobile + web + programming + embedded) / 4.0;
  }

  // Method to determine student status
  String status() {
    double avg = averageGrade();
    if (avg >= 85) return 'excellent';
    if (avg >= 50) return 'pass';
    return 'fail';
  }

  static _randomGrade(int min, int max) {
    return faker.randomGenerator.integer(max, min: min);
  }

  // Named Constructor for random student
  factory Student.random(int id) {
    var name = faker.person.firstName();
    return Student(
      name,
      id,
      _randomGrade(0, 100),
      _randomGrade(0, 100),
      _randomGrade(0, 100),
      _randomGrade(0, 100)
    );
  }

  // Named Constructor for passing students
  factory Student.randomPassing(int id) {
    var name = faker.person.firstName();
    return Student(
      name,
      id,
      _randomGrade(50, 100),
      _randomGrade(50, 100),
      _randomGrade(50, 100),
      _randomGrade(50, 100)
    );
  }

  // Named Constructor for failing students
  factory Student.randomFailing(int id) {
    var name = faker.person.firstName();
    return Student(
      name,
      id,
      _randomGrade(0, 50),
      _randomGrade(0, 50),
      _randomGrade(0, 50),
      _randomGrade(0, 50)
    );
  }

  // Named Constructor for excellent students
  factory Student.randomExcellent(int id) {
    var name = faker.person.firstName();
    return Student(
      name,
      id,
      _randomGrade(85, 100),
      _randomGrade(85, 100),
      _randomGrade(85, 100),
      _randomGrade(85, 100)
    );
  }
}