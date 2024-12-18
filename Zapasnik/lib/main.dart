import 'package:flutter/material.dart';
import 'elementGroups.dart';
import 'serverDataControl.dart';
import 'addGroup.dart';
import 'productList.dart';
import 'addEditProduct.dart';
import 'authController.dart';
import 'authScreen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await ServerDataControl.initialize();

  // статус авторизации
  final isAuthenticated = await AuthController.isAuthenticated();
  final userId = await AuthController.getCurrentUserId();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: isAuthenticated && userId != null
        ? elementGroups(currentUserId: userId)
        : AuthScreen(),
    routes: {
      '/elementGroups': (BuildContext context) => elementGroups(currentUserId: 0,),
      '/addGroup': (BuildContext context) => addGroup(currentUserId: 0,),
      '/productList': (BuildContext context) => ProductList(groupId: 0, groupName: '',),
      '/addEditProduct': (BuildContext context) => AddEditProduct(groupId: 0,),
      '/authScreen': (BuildContext context) => AuthScreen(),
    },
    onGenerateRoute: (routeSettings) {
      var path = routeSettings.name!.split('/');

      if (path[1] == "elementGroups") {
        return new MaterialPageRoute(
          builder: (context) => new elementGroups(currentUserId: 0,),
          settings: routeSettings,
        );
      };

      if (path[1] == "addGroup") {
        return new MaterialPageRoute(
          builder: (context) => new addGroup(currentUserId: 0),
          settings: routeSettings,
        );
      };

      if (path[1] == "productList") {
        return new MaterialPageRoute(
          builder: (context) => new ProductList(groupId: 0, groupName: '',),
          settings: routeSettings,
        );
      };

      if (path[1] == "addEditProduct") {
        return new MaterialPageRoute(
          builder: (context) => new AddEditProduct(groupId: 0),
          settings: routeSettings,
        );
      };

      if (path[1] == "authScreen") {
        return new MaterialPageRoute(
          builder: (context) => new AuthScreen(),
          settings: routeSettings,
        );
      };
      return null;
    },
  ));
}

