import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/pages/household_wizard/register_page.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/utils/utility.dart';
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
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoggingIn = false;

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
        if (!_isLoggingIn) ...[
          SizedBox(
            width: _buttonWidth,
            height: _buttonHeight,
            child: StadiumButton(
                text: 'Register',
                width: _buttonWidth,
                height: _buttonHeight,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => RegisterPage()));
                }),
          ),
          SizedBox(width: _spaceBetweenButtons),
          Text('or'),
          SizedBox(width: _spaceBetweenButtons),
        ],
        SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: _isLoggingIn
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                )
              : StadiumButton(
                  text: 'Log In',
                  width: _buttonWidth,
                  height: _buttonHeight,
                  onPressed: _login),
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

    setState(() {
      _isLoggingIn = true;
    });

    try {
      UserCredential userCredential;
      if (Utility.isValidEmail(usernameOrEmail)) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameOrEmail,
          password: password,
        );
      } else {
        String? email = await _getEmailByUsername(usernameOrEmail);
        if (email == null) {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'User not found');
        }
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        UserService userService = IocContainer.getIt<UserService>();
        await userService.setUserProfile(
            userDoc.data() as Map<String, dynamic>?, userCredential.user!.uid);

        if (mounted) {
          showTopSnackBar(context, 'Login successful.', Colors.green);
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this username or email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      if (mounted) {
        showTopSnackBar(context, errorMessage, Colors.red);
      }
      setState(() {
        _isLoggingIn = false;
      });
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'An unexpected error occurred.', Colors.red);
      }
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<String?> _getEmailByUsername(String username) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.get('email');
    }
    return null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
