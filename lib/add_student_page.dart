import 'package:flutter/material.dart';
import 'package:students/main.dart';
import 'sql_helper.dart'; // Import the DatabaseHelper class

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController rollNoController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  DateTime? selectedDate; // Make selectedDate nullable
  bool agreedToTerms = false; // Track whether the checkbox is checked

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(
                  labelText: 'Name',
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                _buildDateField(
                  labelText: 'Date of Birth',
                  controller: dobController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  labelText: 'Roll No',
                  controller: rollNoController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Roll No is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  labelText: 'Branch',
                  controller: branchController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Branch is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  labelText: 'Subject',
                  controller: subjectController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Subject is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  labelText: 'Marks(in Percentage)',
                  controller: marksController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mark is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                FormField<bool>(
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreedToTerms = value ?? false;
                                  state.didChange(value);
                                });
                              },
                            ),
                            Text('I agree to the terms and conditions'),
                          ],
                        ),
                        if (state.errorText != null)
                          Text(
                            state.errorText!,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (value == false) {
                      return 'You must agree to the terms and conditions';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (!agreedToTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please agree to the terms and conditions',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final name = nameController.text;
                      final rollNo = rollNoController.text;
                      final branch = branchController.text;
                      final marks = int.tryParse(marksController.text) ?? 0;
                      final dob = dobController.text;
                      final subject = subjectController.text;

                      final newRecord = {
                        'name': name,
                        'rollNo': rollNo,
                        'branch': branch,
                        'marks': marks,
                        'dob': dob,
                        'subject': subject
                      };
                      final dbHelper = DatabaseHelper();
                      await dbHelper.insertRecord(newRecord);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDetailsPage(),
                        ),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        onTap: () => _selectDate(context),
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
