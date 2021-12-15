import 'package:flutter/material.dart';
import 'package:inventory/app/api/authentication.dart';
import 'package:inventory/widget/home/employee_home.dart';
import 'package:inventory/widget/home/owner_home.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController _usernameText = TextEditingController();
  TextEditingController _passwordText = TextEditingController();

  void _submitLogin(BuildContext context) async {
    String _usernameValue = _usernameText.text,
        _passwordValue = _passwordText.text;
    if (_loginFormKey.currentState!.validate()) {
      print('username :  $_usernameValue');
      print('password :  $_passwordValue');

      final _login =
          await Authentication().login(_usernameValue, _passwordValue);
      bool _loginsuccess = _login != null && _login.data["code"] == 200;
      bool _noConnection = _login == null;
      bool _userpassWrong = _login != null && _login.data["code"] == 403;

      if (_loginsuccess) {
        String _role = _login.data["data"]["role"];
        if (_role == "employee") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => EmployeeHome()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OwnerHome()));
        }
      } else {
        if (_userpassWrong) {
          print('Username / Password Salah');
        } else if (_noConnection) {
          print('No Connection');
        }
      }
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => EmployeeHome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //kerangk
      body: SafeArea(
        //safeara agar tidak
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _usernameText,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Harus diisi';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextFormField(
                    controller: _passwordText,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Harus diisi';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  ElevatedButton(
                      onPressed: () => _submitLogin(context),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('masuk')],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
