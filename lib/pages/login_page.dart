import 'package:flutter/material.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/pages/registration_page.dart';

import 'home_page.dart';

const _appMargin = 40.0;
const _spaceAfterPassword = 15.0;
const _spaceBetweenButtons = 10.0;
const _spaceBeforeErrorText = 5.0;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool isError;

  @override
  void initState() {
    isError = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return PageTemplate(
      title: 'HouseHold Manager - Login',
      child: Container(
        margin: EdgeInsets.all(_appMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField('Username', usernameController, false),
            _buildTextField('Password', passwordController, true),
            SizedBox(height: _spaceAfterPassword),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStadiumButton('Register', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => RegistrationPage()));
                }),
                SizedBox(width: _spaceBetweenButtons),
                Text('or'),
                SizedBox(width: _spaceBetweenButtons),
                _buildStadiumButton('Log In', () {
                  if (checkLoginInfo(
                      usernameController.text, passwordController.text)) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                        (_) => false);
                  } else {
                    setState(() => isError = true);
                  }
                }),
              ],
            ),
            if (isError) ...[
              SizedBox(height: _spaceBeforeErrorText),
              Text(
                'Invalid username or password',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
    String labelText, TextEditingController controller, bool obscureText) {
  return TextField(
    decoration: InputDecoration(labelText: labelText),
    controller: controller,
    obscureText: obscureText,
    enableSuggestions: false,
    autocorrect: false,
  );
}

Widget _buildStadiumButton(String text, Function onPressed) {
  return ElevatedButton(
    onPressed: () => onPressed(),
    child: Text(text),
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(StadiumBorder()),
    ),
  );
}

bool checkLoginInfo(String username, String password) {
  if (username.isEmpty || password.isEmpty) {
    return false;
  }
  // TODO
  return true;
}
