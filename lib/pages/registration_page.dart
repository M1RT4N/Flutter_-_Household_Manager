import 'package:flutter/material.dart';
import 'package:household_manager/pages/common/page_template.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      appBar: AppBar(
        title: Text('HouseHold Manager - Register'),
        centerTitle: true,
      ),
      child: Text('HouseHold Manager - Register'),
    );
  }
}
