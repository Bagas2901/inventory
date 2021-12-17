import 'package:flutter/material.dart';
import 'package:inventory/app/api/authentication.dart';
import 'package:inventory/app/data_class/auth_type.dart';
import 'package:inventory/widget/home/employee_home.dart';
import 'package:inventory/widget/home/owner_home.dart';

import 'login.dart';

class Splashscreen extends StatefulWidget {
  Splashscreen({Key? key}) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    Authentication().checkAuth().then((value) => {
          if (value?.isLoggedin == true)
            {
              //sudah login
              //jika owner
              if (value?.role == 'owner')
                {
                  Future.delayed(
                      Duration(seconds: 2),
                      () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => OwnerHome())))
                }
              //jika karyawan
              else
                {
                  Future.delayed(
                      Duration(seconds: 2),
                      () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmployeeHome())))
                }
            }
          else
            {
              //belum login
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Login()))
            }
        });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Text('Ini SplashScreen'),
    ));
  }
}
