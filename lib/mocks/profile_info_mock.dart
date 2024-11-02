import 'package:household_manager/models/profile_info.dart';

class ProfileInfoMock {
  final ProfileInfo _profileInfo =
      ProfileInfo(firstName: "Jozef", lastName: "Smutny");
  final String _username = "u";
  final String _password = "u";

  bool checkLoginInfo(String username, String password) {
    return _username == username && _password == password;
  }

  ProfileInfo getProfileInfo() {
    return _profileInfo;
  }
}
