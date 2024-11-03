import 'package:flutter/material.dart';
import 'package:household_manager/mocks/profile_info_mock.dart';
import 'package:household_manager/pages/home_page.dart';
import 'package:household_manager/pages/registration_page.dart';

const _appMargin = 40.0;
const _spaceAfterPassword = 15.0;
const _spaceBetweenButtons = 10.0;
const _spaceBeforeErrorText = 5.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isError = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HouseHold Manager - Login'),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(_appMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField('Username', _usernameController, false),
            _buildTextField('Password', _passwordController, true),
            SizedBox(height: _spaceAfterPassword),
            _buildButtons(),
            if (_isError) ...[
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

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStadiumButton('Register', () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => RegistrationPage()));
        }),
        SizedBox(width: _spaceBetweenButtons),
        Text('or'),
        SizedBox(width: _spaceBetweenButtons),
        _buildStadiumButton('Log In', () {
          final username = _usernameController.text;
          final password = _passwordController.text;

          if (username.isNotEmpty &&
              password.isNotEmpty &&
              ProfileInfoMock().checkLoginInfo(username, password)) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    profileInfo: ProfileInfoMock().getProfileInfo(),
                  ),
                ),
                (_) => false);
          } else {
            setState(() => _isError = true);
          }
        }),
      ],
    );
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
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(StadiumBorder()),
      ),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
