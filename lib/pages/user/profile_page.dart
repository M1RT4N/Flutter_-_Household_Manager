import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/form_text_field.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:household_manager/widgets/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

const _avatarSizeLimit = 50; // In MB
const _controlButtonsSpacing = 10.0;
const _avatarSize = 100.0;
const _avatarEditIconSize = 16.0;
const _cardHeaderPadding = 16.0;
const _cardHeaderFontSize = 20.0;
const _controlButtonsPadding = 20.0;
const _cardInnerPaddingVertical = 25.0;
const _cardInnerPaddingHorizontal = 80.0;
const _cardSizeFactor = 2.0;
const _cardElevation = 4.0;
const _cardMargin = 16.0;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _userService = GetIt.instance<UserService>();
  final _picker = ImagePicker();

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return LoadingStreamBuilder(
      stream: _userService.getUserStream,
      builder: (context, user_) {
        final user = user_! as User;
        final haveHousehold =
            user.householdId != null && user.householdId!.isNotEmpty;

        return PageTemplate(
          title: 'Profile',
          bodyFunction: (context) => _buildBody(context, user),
          showDrawer: haveHousehold,
          showBackArrow: !haveHousehold,
          showNotifications: haveHousehold,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, User user) {
    _usernameController.text = user.username;
    _nameController.text = user.name;

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / _cardSizeFactor,
          child: Column(
            children: [
              _buildUserDetailsCard(user),
              _buildChangePasswordCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(User user) {
    return Card(
      elevation: _cardElevation,
      margin: const EdgeInsets.all(_cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardHeader('User Details'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _cardInnerPaddingHorizontal,
              vertical: _cardInnerPaddingVertical,
            ),
            child: Column(
              children: [
                _buildAvatarSection(),
                FormTextField(
                  labelText: 'Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                FormTextField(
                  labelText: 'Username',
                  controller: _usernameController,
                  icon: Icons.person,
                ),
                FormTextField(
                  labelText: 'Email',
                  controller: TextEditingController(text: user.email),
                  icon: Icons.email,
                  enabled: false,
                ),
                SizedBox(height: _controlButtonsPadding),
                _buildActionButtons(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard() {
    return Card(
      elevation: _cardElevation,
      margin: const EdgeInsets.all(_cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardHeader('Change Password'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _cardInnerPaddingHorizontal,
              vertical: _cardInnerPaddingVertical,
            ),
            child: Column(
              children: [
                FormTextField(
                  labelText: 'Current Password',
                  controller: _currentPasswordController,
                  obscureText: true,
                  icon: Icons.lock_open,
                ),
                FormTextField(
                  labelText: 'New Password',
                  controller: _newPasswordController,
                  obscureText: true,
                  icon: Icons.lock,
                ),
                FormTextField(
                  labelText: 'Confirm New Password',
                  controller: _confirmNewPasswordController,
                  obscureText: true,
                  icon: Icons.lock_reset,
                ),
                SizedBox(height: _controlButtonsPadding),
                LoadingStadiumButton(
                  buttonText: 'Save',
                  onPressed: _changePassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(_cardHeaderPadding),
      color: Colors.blueGrey,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: _cardHeaderFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return IconButton(
      iconSize: _avatarSize,
      icon: Stack(
        alignment: Alignment.bottomRight,
        children: [
          UserAvatar(
            onPressed: _pickImage,
            initialsRadius: _avatarSize,
          ),
          CircleAvatar(
            radius: _avatarEditIconSize,
            backgroundColor: Colors.grey[400],
            child: Icon(
              Icons.edit,
              color: Colors.black,
            ),
          ),
        ],
      ),
      onPressed: _pickImage,
    );
  }

  Widget _buildActionButtons(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoadingStadiumButton(
          buttonText: 'Update',
          onPressed: () => _saveProfile(user),
        ),
        SizedBox(width: _controlButtonsSpacing),
        LoadingStadiumButton(
          buttonText: 'Reset',
          onPressed: () {
            setState(() {
              _usernameController.text = user.username;
              _nameController.text = user.name;
            });
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileSize = await pickedFile.length();
      if (fileSize > _avatarSizeLimit * 1024 * 1024 && mounted) {
        showTopSnackBar(context,
            'File size exceeds ${_avatarSizeLimit}MB limit.', Colors.red);
        return;
      }

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await _uploadImage(bytes: bytes);
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadImage(file: _imageFile);
      }
    }
  }

  Future<void> _uploadImage({Uint8List? bytes, File? file}) async {
    final user = _userService.getUser;
    if (user == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_avatars')
        .child('${user.id}.jpg');

    try {
      if (bytes != null) {
        await storageRef.putData(bytes);
      } else if (file != null) {
        await storageRef.putFile(file);
      }
      final downloadUrl = await storageRef.getDownloadURL();
      await _userService.updateUserProfile(
        user.username,
        user.name,
        downloadUrl,
      );
      if (mounted) {
        showTopSnackBar(context, 'Image uploaded successfully.', Colors.green);
      }
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'Failed to upload image: $e', Colors.red);
      }
    }
  }

  String? _validateInputs() {
    if (_usernameController.text.isEmpty) {
      return 'Username is required.';
    }
    if (_nameController.text.isEmpty) {
      return 'Name is required.';
    }

    return null;
  }

  void _saveProfile(User user) async {
    var errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    errorMessage = await _userService.updateUserProfile(
        _usernameController.text, _nameController.text, user.avatarUrl);
    if (mounted) {
      if (errorMessage != null) {
        return showTopSnackBar(context, errorMessage, Colors.red);
      }

      showTopSnackBar(context, 'Profile updated successfully.', Colors.green);
    }
  }

  String? _validatePasswordInputs() {
    if (_currentPasswordController.text.isEmpty) {
      return 'Current password is required.';
    }
    if (_newPasswordController.text.isEmpty) {
      return 'New password is required.';
    }
    if (_newPasswordController.text.length < 6) {
      return 'New password must be at least 6 characters long.';
    }
    if (_confirmNewPasswordController.text.isEmpty) {
      return 'Please confirm your new password.';
    }
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      return 'New passwords do not match.';
    }
    return null;
  }

  void _changePassword() async {
    var errorMessage = _validatePasswordInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    try {
      auth.User? user = auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cred = auth.EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);
        if (mounted) {
          showTopSnackBar(
              context, 'Password changed successfully.', Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'Failed to change password: $e', Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
