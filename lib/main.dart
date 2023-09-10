import 'package:flutter/material.dart';
import 'add_student_page.dart'; // Import the add_student_page.dart file
import 'sql_helper.dart'; // Import the DatabaseHelper class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management System',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Student Management System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true, // Center the title text
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20), // Add some spacing
            _buildActionButton(
              icon: Icons.add,
              label: 'Add Student',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStudentPage()),
                );
                // Add student functionality here
              },
            ),
            SizedBox(height: 20), // Add spacing between buttons
            _buildActionButton(
              icon: Icons.visibility,
              label: 'View Details',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDetailsPage()),
                );
                // View student details functionality here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // You can set your desired color here
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ViewDetailsPage extends StatefulWidget {
  @override
  _ViewDetailsPageState createState() => _ViewDetailsPageState();
}

class _ViewDetailsPageState extends State<ViewDetailsPage> {
  late Future<List<Map<String, dynamic>>>
      studentData; // Use a Future for loading data

  @override
  void initState() {
    super.initState();
    studentData = _loadStudentData();
    print(studentData);
  }

  Future<List<Map<String, dynamic>>> _loadStudentData() async {
    final dbHelper = DatabaseHelper();
    return dbHelper.getAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Navigate back to the "Main Page" when the back button is pressed
          Navigator.popUntil(
              context,
              ModalRoute.withName(
                  '/')); // Replace '/' with your main page route
          return false; // Return false to prevent default back button behavior
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Student Details'),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: studentData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No student records available.'),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final student = snapshot.data![index];
                    return _buildStudentCard(student, context);
                  },
                );
              }
            },
          ),
        ));
  }

  Widget _buildStudentCard(Map<String, dynamic> student, BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text('Name: ${student['name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Date of Birth: ${student['dob']}'),
            Text('Roll No: ${student['rollNo']}'),
            Text('Branch: ${student['branch']}'),
            Text('Subject: ${student['subject']}'),
            Text('Marks: ${student['marks']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove_red_eye), // View icon
              onPressed: () {
                // Show student details in a modal
                _showStudentDetailsModal(student, context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete), // Delete icon
              onPressed: () async {
                // Call deleteRecord when the delete icon is pressed
                await _deleteStudentRecord(student[
                    'id']); // Replace 'id' with your actual ID field name
                // Reload the studentData after deletion
                setState(() {
                  studentData = _loadStudentData();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteStudentRecord(int id) async {
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteRecord(id);
}

void _showStudentDetailsModal(
    Map<String, dynamic> student, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity, // Full screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.close), // Close icon
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                    },
                  ),
                ],
              ),
              Text('Name: ${student['name']}'),
              Text('Date of Birth: ${student['dob']}'),
              Text('Roll No: ${student['rollNo']}'),
              Text('Branch: ${student['branch']}'),
              Text('Subject: ${student['subject']}'),
              Text('Marks: ${student['marks']}'),

              SizedBox(height: 16.0),
              // Add more student details here if needed
            ],
          ),
        ),
      );
    },
  );
}
