import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/widgets/form_text_field.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:household_manager/widgets/stadium_button.dart';

const _containerPadding = 16.0;
const _maxContainerWidth = 400.0;
const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
const _spaceAfterPassword = 35.0;
const _spaceBetweenButtons = 10.0;

class LoginPage extends StatefulWidget {
  final UserService userService = IocContainer.getIt<UserService>();

  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HouseHold Manager - Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(_containerPadding),
          constraints: BoxConstraints(maxWidth: _maxContainerWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormTextField(
                labelText: 'Username',
                controller: _usernameController,
                icon: Icons.person,
              ),
              FormTextField(
                labelText: 'Password',
                controller: _passwordController,
                obscureText: true,
                icon: Icons.lock,
              ),
              SizedBox(height: _spaceAfterPassword),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: StadiumButton(
              text: 'Register',
              width: _buttonWidth,
              height: _buttonHeight,
              onPressed: () {
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (_) => RegisterPage()));
              }),
        ),
        SizedBox(width: _spaceBetweenButtons),
        Text('or'),
        SizedBox(width: _spaceBetweenButtons),
        EasyButton(
          width: _buttonWidth,
          height: _buttonHeight,
          idleStateWidget: Text('Log In'),
          loadingStateWidget: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          onPressed: () => _login,
        )
      ],
    );
  }

  bool _validateInputs(String usernameOrEmail, String password) {
    if (usernameOrEmail.isEmpty || password.isEmpty) {
      showTopSnackBar(
        context,
        'Please enter both username and password.',
        Colors.red,
      );
      return false;
    }
    return true;
  }

  void _login() async {
    final usernameOrEmail = _usernameController.text;
    final password = _passwordController.text;

    if (!_validateInputs(usernameOrEmail, password)) {
      return;
    }

    var res = await widget.userService.tryLogin(usernameOrEmail, password);
    if (res == null) {
      if (mounted) {
        showTopSnackBar(context,
            'Login failed: ${widget.userService.getError!}', Colors.red);
        return;
      }
    }

    if (mounted) {
      showTopSnackBar(context, 'Login successful.', Colors.green);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
