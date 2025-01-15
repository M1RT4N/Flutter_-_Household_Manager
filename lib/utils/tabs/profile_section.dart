enum ProfileSection {
  UserDetail('User Detail'),
  ChangePass('Change Password');

  final String customName;

  const ProfileSection(this.customName);

  @override
  toString() => customName;
}
