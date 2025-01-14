import 'package:flutter/material.dart';
import 'package:waiter/app/modules/home/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:waiter/app/modules/home/controllers/home_controller.dart';
import 'package:waiter/app/modules/order_list/controllers/order_list_controller.dart';
import 'package:waiter/app/modules/tasks/controllers/tasks_controller.dart';
import 'package:waiter/app/routes/app_pages.dart';


class DrawerWidget extends StatelessWidget {
  final AuthController _userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
     elevation: 0.0,
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
            Get.back();
              //Get.toNamed(DeliveryBoyOrdersScreen.pageId, arguments: 0);
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Get.theme.hintColor.withOpacity(0.1),
//              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35)),
              ),
              accountName: Text('${_userController.currentUser.username??''}',
                style: Get.theme.textTheme.headline6,
              ),
              accountEmail: Text(
                "${_userController.currentUser.email??''}",
                style: Get.theme.textTheme.caption,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Get.theme.accentColor,
//                      backgroundImage: NetworkImage(currentUser.value.image.thumb),
              ),
            ),
          ),
            //  delivery boy

            ListTile(
              onTap: () {
                Get.reload<HomeController>();
                Get.back();
                Get.toNamed(Routes.HOME);
              },
              leading: Icon(
                Icons.delivery_dining,
                // color: Get.theme.focusColor.withOpacity(1),
              ),
              title: Text( 'Categories'.tr,
                style:Get.theme.textTheme.subtitle1,
              ),
            ),

          ListTile(
            onTap: () {

              // Get.reload<OrderListController>(force: true);
              Get.put(OrderListController()).reloadFunction();
              Get.back();
              Get.toNamed(Routes.ORDER_LIST);
            },
            leading: Icon(
              Icons.shop_two_sharp,
              color: Get.theme.focusColor.withOpacity(1),
            ),
            title: Text(
              'OrderList'.tr,
              style:Get.theme.textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              Get.reload<TasksController>(force: true);

              Get.back();
              Get.toNamed(Routes.TASKS);
            },
            leading: Icon(
              Icons.task,
              color: Get.theme.focusColor.withOpacity(1),
            ),
            title: Text(
              'Tasks'.tr,
              style:Get.theme.textTheme.subtitle1,
            ),
          ),
      /*    ListTile(
            onTap: () {
              Get.back();
              Get.toNamed(Routes.ORDER_HISTORY);
            },
            leading: Icon(
              Icons.history,
              color: Get.theme.focusColor.withOpacity(1),
            ),
            title: Text(
              'OrderHistory'.tr,
              style:Get.theme.textTheme.subtitle1,
            ),
          ),*/

          ListTile(
            dense: true,
            title: Text(
              'application_preferences'.tr,
              style: Get.textTheme.bodyText2,
            ),
            trailing: Icon(
              Icons.remove,
              color: Get.theme.focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              Get.back();
              Get.toNamed(Routes.LANGUAGE, arguments: 0);
            },
            leading: Icon(
              Icons.translate,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              'languages'.tr,
              style: Get.textTheme.subtitle1,
            ),
          ),

          ListTile(
            onTap: () {
              Get.back();
              if (Get.isDarkMode)
                Get.changeThemeMode(ThemeMode.light);
              else
                Get.changeThemeMode(ThemeMode.dark);
            },
            leading: Icon(
              Icons.brightness_6,
              color: Get.theme.focusColor.withOpacity(1),
            ),
            title: Text(Get.isDarkMode
                  ? 'light_mode'.tr
                  : 'dark_mode'.tr,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          ListTile(
            onTap: () {
              // Get.back();
             _userController.signOutUser();
            },
            leading: Icon(
              Icons.exit_to_app,
              color: Get.theme.focusColor.withOpacity(1),
            ),
            title: Text(
              'log_out'.tr,
              style: Get.theme.textTheme.subtitle1,
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }
}
