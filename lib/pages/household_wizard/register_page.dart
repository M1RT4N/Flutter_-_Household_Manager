import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/form_text_field.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _containerPadding = 16.0;
const _maxContainerWidth = 400.0;
const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
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

  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
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
              SizedBox(
                width: _buttonWidth,
                height: _buttonHeight,
                child: _isRegistering
                    ? Center(
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                        ),
                        child: Text('Register'),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty) {
      showTopSnackBar(context, 'Email is required.', Colors.red);
      return false;
    }
    if (!Utility.isValidEmail(_emailController.text)) {
      showTopSnackBar(
          context, 'Please enter a valid email address.', Colors.red);
      return false;
    }
    if (_usernameController.text.isEmpty) {
      showTopSnackBar(context, 'Username is required.', Colors.red);
      return false;
    }
    if (_nameController.text.isEmpty) {
      showTopSnackBar(context, 'Name is required.', Colors.red);
      return false;
    }
    if (_passwordController.text.isEmpty) {
      showTopSnackBar(context, 'Password is required.', Colors.red);
      return false;
    }
    if (_passwordController.text.length < _minPasswordLength) {
      showTopSnackBar(
          context,
          'Password must be at least $_minPasswordLength characters long.',
          Colors.red);
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      showTopSnackBar(context, 'Please confirm your password.', Colors.red);
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showTopSnackBar(context, 'Passwords do not match.', Colors.red);
      return false;
    }
    return true;
  }

  void _register() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'username': _usernameController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'created_at': Timestamp.now(),
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        UserService userService = IocContainer.getIt<UserService>();
        await userService.setUserProfile(
            userDoc.data() as Map<String, dynamic>?, userCredential.user!.uid);

        setState(() {
          _isRegistering = false;
        });
        if (mounted) {
          showTopSnackBar(context, 'Registration successful.', Colors.green);
          Navigator.pushReplacementNamed(context, '/choose_household');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isRegistering = false;
      });

      String errorMessage = 'An error occurred.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      if (mounted) {
        showTopSnackBar(context, errorMessage, Colors.red);
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });

      if (mounted) {
        showTopSnackBar(
            context, 'An unexpected error occurred: $e', Colors.red);
      }
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
