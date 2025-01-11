import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/form_text_field.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _containerPadding = 16.0;
const _maxContainerWidth = 400.0;
const _minPasswordLength = 6; // In symbols
const _spacingHeight = 20.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userService = IocContainer.getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Modular.to.pushNamed(AppRoute.login.path),
        ),
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
              FormTextField(
                labelText: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                icon: Icons.lock,
              ),
              FormTextField(
                labelText: 'Email',
                controller: _emailController,
                icon: Icons.email,
              ),
              FormTextField(
                labelText: 'Name',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              SizedBox(height: _spacingHeight),
              LoadingStadiumButton(
                  idleStateWidget: Text('Register'), onPressed: _register)
            ],
          ),
        ),
      ),
    );
  }

  String? _validateInputs() {
    if (_emailController.text.isEmpty) {
      return 'Email is required.';
    }
    if (!Utility.isValidEmail(_emailController.text)) {
      return 'Please enter a valid email address.';
    }
    if (_usernameController.text.isEmpty) {
      return 'Username is required.';
    }
    if (_nameController.text.isEmpty) {
      return 'Name is required.';
    }
    if (_passwordController.text.isEmpty) {
      return 'Password is required.';
    }
    if (_passwordController.text.length < _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters long.';
    }
    if (_confirmPasswordController.text.isEmpty) {
      return 'Please confirm your password.';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  void _register() async {
    var errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    errorMessage = await _userService.tryRegister(_usernameController.text,
        _nameController.text, _emailController.text, _passwordController.text);
    if (mounted) {
      if (errorMessage != null) {
        return showTopSnackBar(context, errorMessage, Colors.red);
      }

      showTopSnackBar(context, 'Registration successful.', Colors.green);
      Modular.to.navigate(AppRoute.chooseHousehold.route);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
