import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(
    MaterialApp(
      home: ContactForm(),
    ),
  );
}

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> { // CONTROLLER FIELDS
  var _nameFieldController = TextEditingController();
  var _emailFieldController = TextEditingController();
  var _phoneFieldController = TextEditingController();
  var _passwordFieldController = TextEditingController();
  var _confirmPasswordFieldController = TextEditingController();

  bool isValidEmail(String input) {
    final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(input);
  }

  bool isValidPhoneNumber(String input) {
    final phoneRegExp = RegExp(r'^\d{10}$');
    return phoneRegExp.hasMatch(input);
  }

  bool isValidPassword(String input) {

    if (input.length < 6) { // Check for minimum length
      return false;
    }

    if (!RegExp(r'[A-Z]').hasMatch(input)) {// Check for at least one uppercase letter
      return false;
    }

    if (!RegExp(r'[a-z]').hasMatch(input)) { // Check for at least one lowercase letter
      return false;
    }

    if (!RegExp(r'[0-9]').hasMatch(input)) {// Check for at least one number
      return false;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(input)) {// Check for at least one special character
      return false;
    }

    if (input.contains(' ')) { // Check for no spaces
      return false;
    }
    return true;
  }

  final _formKey = GlobalKey<FormState>();

  void _showAlert(BuildContext context, String title, String message, AlertType alertType) {
    Alert(
      context: context,
      type: alertType,
      title: title,
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Validation'),
        backgroundColor: Colors.teal[10],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            TextFormField(
              decoration: InputDecoration( // NAME FORM FIELD
                icon: Icon(Icons.person),
                hintText: 'Enter your name',
                labelText: 'Name',
              ),
              keyboardType: TextInputType.text,
              controller: _nameFieldController,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),

            TextFormField(
              decoration: InputDecoration( // EMAIL FORM FIELD
                icon: Icon(Icons.email),
                hintText: 'Enter your email',
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailFieldController,
              validator: (val) =>
              isValidEmail(val!) ? null : 'Invalid email',
            ),

            TextFormField(
              decoration: InputDecoration( // PHONE NUMBER FORM FIELD
                icon: Icon(Icons.phone),
                hintText: 'Enter Phone number',
                labelText: 'Phone number',
              ),
              keyboardType: TextInputType.phone,
              controller: _phoneFieldController,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Phone number is required';
                } else if (!isValidPhoneNumber(val)) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),

            TextFormField(
              decoration: InputDecoration( // PASSWORD FORM FIELD
                icon: Icon(Icons.lock),
                hintText: 'Enter Password',
                labelText: 'Password',
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              controller: _passwordFieldController,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Password is required';
                } else if (!isValidPassword(val)) {
                  return 'Password invalid must be at least 6 characters';
                }
                return null;
              },
            ),

            TextFormField(
              decoration: InputDecoration(// PASSWORD CONFIRMATION FORM FIELD
                icon: Icon(Icons.lock),
                hintText: 'Confirm password',
                labelText: 'Enter password again',
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              controller: _confirmPasswordFieldController,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Confirm password is required';
                } else if (val != _passwordFieldController.text) {
                  return 'Password do not match';
                }
                return null;
              },
            ),

            Container( // SUBMIT BUTTON
              padding: EdgeInsets.only(left: 40, top: 40, right: 40),
              child: ElevatedButton(
                child: Text('Submit'),
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, show success alert
                    _showAlert(
                      context,
                      'Success',
                      'Form submitted successfully!',
                      AlertType.success,
                    );
                  } else {
                    // If the form is invalid, show error alert
                    _showAlert(
                      context,
                      'Error',
                      'Please fix the errors in the form.',
                      AlertType.error,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}