import 'package:flutter/material.dart';
import 'package:tms_mobile_map/Models/login_model.dart';

class LoginScreen extends StatelessWidget {
  final LoginModel loginModel;

  const LoginScreen({super.key, required this.loginModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child:
                    Text("Access Token: ${loginModel.accessToken ?? "N/A"}")),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("First Name: ${loginModel.firstName ?? "N/A"}")),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Middle Name: ${loginModel.middleName ?? "N/A"}")),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Age: ${loginModel.age ?? "N/A"}")),
          ],
        ),
      ),
    );
  }
}
