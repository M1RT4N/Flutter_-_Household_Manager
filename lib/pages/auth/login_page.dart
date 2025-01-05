import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/form_text_field.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _containerPadding = 16.0;
const _maxContainerWidth = 400.0;
const _spaceAfterPassword = 35.0;
const _spaceBetweenButtons = 10.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final UserService _userService = IocContainer.getIt<UserService>();

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
        LoadingStadiumButton(
            buttonText: 'Register',
            onPressed: () => Modular.to.navigate(AppRoute.register.path)),
        SizedBox(width: _spaceBetweenButtons),
        Text('or'),
        SizedBox(width: _spaceBetweenButtons),
        LoadingStadiumButton(buttonText: 'Login', onPressed: _login),
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
      if (mounted) {
        return showTopSnackBar(
            context, 'Please fill both username and password.', Colors.red);
      }
    }

    final errorMessage = await _userService.tryLogin(usernameOrEmail, password);
    if (errorMessage != null) {
      if (mounted) {
        return showTopSnackBar(
            context, 'Login failed: $errorMessage', Colors.red);
      }
    }

    if (mounted) {
      showTopSnackBar(context, 'Login successful.', Colors.green);
      Modular.to.navigate(AppRoute.home.path);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
