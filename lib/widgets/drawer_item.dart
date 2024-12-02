import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String nextPageRoute;

  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.nextPageRoute});

  @override
  Widget build(BuildContext context) {
    bool isSelected = Modular.to.path == nextPageRoute;

    return ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : null),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          if (isSelected) {
            Modular.to.pop(context);
            return;
          }

          Modular.to.popAndPushNamed(nextPageRoute);
        });
  }
}
