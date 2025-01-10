import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/static_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _pendingSize = 100.0;
const _pendingIconSize = 80.0;
const _pendingGapSize = 20.0;
const _cancelButtonWidth = 200.0;
const _cancelButtonHeight = 50.0;
const _cancelButtonFontSize = 16.0;
const _textFontSize = 18.0;
const _warningBoxPadding = 16.0;
const _warningBoxRadius = 8.0;
const _animationDelay = 0.5;

class HouseholdRequestPage extends StatefulWidget {
  const HouseholdRequestPage({super.key});

  @override
  State<HouseholdRequestPage> createState() => _HouseholdRequestPageState();
}

class _HouseholdRequestPageState extends State<HouseholdRequestPage> {
  final _userService = GetIt.instance<UserService>();
  final _householdService = GetIt.instance<HouseholdService>();

  // TODO: we have loading page template -> use it instead of this nonsense
  @override
  Widget build(BuildContext context) {
    // NOTE: MicroTask is used to push the route after the current build is done
    //       to ensure that we would not loop infinitely between chooseHousehold
    //       and this page.
    return LoadingStreamBuilder<User?>(
      stream: _userService.getUserStream,
      builder: (context, user) {
        if (user == null) {
          Future.microtask(
              () => Modular.to.pushNamed(AppRoute.chooseHousehold.path));
          return Container();
        }

        if (user.requestedId != null && user.requestedId!.isNotEmpty) {
          return _buildPage(
              context, (context) => _buildPendingContent(context));
        }

        if (user.householdId != null && user.householdId!.isNotEmpty) {
          Future.microtask(() => Modular.to.pushNamed(AppRoute.home.path));
          return Container();
        }

        Future.microtask(
            () => Modular.to.pushNamed(AppRoute.chooseHousehold.path));
        return Container();
      },
    );
  }

  Widget _buildPage(BuildContext context, bodyBuilder) {
    return StaticPageTemplate(
      title: 'Household Request',
      bodyFunction: bodyBuilder,
      showDrawer: false,
      showNotifications: false,
      showLogout: true,
    );
  }

  Widget _buildPendingContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _pendingSize,
            height: _pendingSize,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(_animationDelay),
              child: Icon(
                Icons.sync,
                size: _pendingIconSize,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: _pendingGapSize),
          _buildWarningBox(),
          SizedBox(height: _pendingGapSize),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Card _buildWarningBox() {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_warningBoxRadius),
        side: BorderSide(color: Colors.yellow),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_warningBoxPadding),
        child: Text(
          'Please wait while we await confirmation from your household members.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _textFontSize, color: Colors.black87),
        ),
      ),
    );
  }

  SizedBox _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: _cancelButtonWidth,
      height: _cancelButtonHeight,
      child: ElevatedButton(
        onPressed: () => _cancelRequest(context),
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(
          'Cancel Request',
          style: TextStyle(fontSize: _cancelButtonFontSize),
        ),
      ),
    );
  }

  void _cancelRequest(BuildContext context) async {
    String? householdId = _userService.getUser?.requestedId;
    if (householdId == null) {
      return;
    }

    final errorMessage = await _householdService.cancelHouseholdRequest();
    if (context.mounted) {
      if (errorMessage != null) {
        return showTopSnackBar(context, errorMessage, Colors.red);
      }

      showTopSnackBar(context, 'Request cancelled successfully.', Colors.green);
      Modular.to.navigate(AppRoute.chooseHousehold.route);
    }
  }
}
