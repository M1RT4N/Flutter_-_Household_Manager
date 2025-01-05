import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/household_button.dart';

const _mainButtonGap = 20.0;

class ChooseHouseholdPage extends StatelessWidget {
  const ChooseHouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Choose Household',
      showDrawer: false,
      showLogout: true,
      showNotifications: false,
      bodyFunction: _buildMainContent,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Wrap(
              runSpacing: _mainButtonGap,
              children: [
                HouseholdButton(
                    icon: Icons.home,
                    label: 'Enter Existing Household',
                    onPressed: () =>
                        Modular.to.pushNamed(AppRoute.joinHousehold.path)),
                const SizedBox(width: _mainButtonGap),
                HouseholdButton(
                  icon: Icons.add,
                  label: 'Create New Household',
                  onPressed: () =>
                      Modular.to.pushNamed(AppRoute.createHousehold.path),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
