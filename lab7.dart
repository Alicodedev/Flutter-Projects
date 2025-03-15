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

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts Demo'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed:(){
              Navigator.pushNamed(context, '/bar'); // Navigate to bar chart route
            },
            child: const Text('Go back Home') ),


      )
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

  late List<Student> students = [];

  // this method generates random student
  generateRandomStudents() {
    students.clear();
    var numberOfStudents = 5;
    for (var i = 0; i < numberOfStudents; i++) {
      var student = Student.random(i + 1);
      students.add(student);
    }
  }

  // generate the dataList for the bar chart
  generateChartData() {
    for (int i = 0; i < students.length; i++) {
      Student student = students[i];
      BarChartGroupData barChartGroupData = BarChartGroupData(x: i,
        barRods: [
          BarChartRodData(toY: student.mobile.toDouble(), color: Colors.red),
          BarChartRodData(toY: student.web.toDouble(), color: Colors.blue),
        ],
      );
      dataList.add(barChartGroupData);
    }
  }


  // this method is to return x-axis tick labels (student names)
  Widget getTitles(double value, TitleMeta meta) {
    return Text(students[value.toInt()].name, style: TextStyle(color: Colors.blue),);
  }

  // initialize data
  @override
  void initState() {
    super.initState();
    generateRandomStudents();
    generateChartData();
  }

  @override
  Widget build(BuildContext context) {

    return BarChart(
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
      duration: Duration(milliseconds: 150), // Optional
      curve: Curves.linear, // Optional
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
  late List<Student> students = [];

  // Similar to your bar chart, generate random students
  generateRandomStudents() {
    students.clear();
    var numberOfStudents = 5;
    for (var i = 0; i < numberOfStudents; i++) {
      var student = Student.random(i + 1);
      students.add(student);
    }
  }

  // Generate line chart data
  generateChartData() {
    // Create line data for mobile scores
    var mobileScores = LineChartBarData(
      isCurved: true,
      color: Colors.red,
      barWidth: 2,
      spots: students.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.mobile.toDouble());
      }).toList(),
    );

    // Create line data for web scores
    var webScores = LineChartBarData(
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      spots: students.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.web.toDouble());
      }).toList(),
    );

    dataList = [mobileScores, webScores];
  }


  Widget getTitles(double value, TitleMeta meta) {
    return Text(students[value.toInt()].name, style: TextStyle(color: Colors.blue));
  }

  @override
  void initState() {
    super.initState();
    generateRandomStudents();
    generateChartData();
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
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
    );
  }
}
// *** END LINE CHART ROUTE

class Student {
  static int count = 0;
  late String name;
  late int studentID;
  late int mobile;
  late int web;

  // Default Constructor
  Student(String n, int id, int m, int w) {
    count++;
    name = n;
    studentID = id;
    mobile = m;
    web = w;
  }

  static _randomGrade(int min, int max) {
    return faker.randomGenerator.integer(max, min: min);
  }

  // Named Constructor
  factory Student.random(int id) {
    var name = faker.person.firstName();
    return Student(name, id, _randomGrade(0, 100), _randomGrade(0, 100));
  }

  factory Student.randomPassing(int id) {
    var name = faker.person.firstName();
    return Student(name, id, _randomGrade(50, 100), _randomGrade(50, 100));
  }

  factory Student.randomFailing(int id) {
    var name = faker.person.firstName();
    return Student(name, id, _randomGrade(0, 50), _randomGrade(0, 50));
  }
}
