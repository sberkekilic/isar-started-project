import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../api/system_api.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../localizations/localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SettingsCubit settings;
  String email = "";
  String password = "";
  List<String> warnings = [];
  bool loading = false;

  void showWarnings() {
    showDialog(
        context: context,
        builder:(context) => CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context).getTranslate('warning')),
      actions: [
        CupertinoDialogAction(
          onPressed: ()=>Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).getTranslate('close')),
        ),
      ],
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: warnings
              .map(
                  (e) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context).getTranslate(e),
                textAlign: TextAlign.start,
              ))).toList()
      ),
    ));
  }

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    final List<String> msgs =[];
    if(email.trim().isEmpty) {
      msgs.add("mail_required");
    }
    if(password.trim().length < 6) {
      msgs.add("passwd_length");
    }

    final bool emailValid =
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

    if(!emailValid) {
      msgs.add("email_format");
    }

    if(msgs.isEmpty) {
      // everything is ok
      // i can login
      final loginResult = await performLogin(email, password);

      if (loginResult != null){
        final data = [
          loginResult["name"],
          loginResult["email"],
          loginResult["phone"],
          loginResult["token"],
        ];
        final dataList = data.map((value) => value.toString()).toList();
        settings.userLogin(dataList);
        GoRouter.of(context).replace('/home');
      } else {
        warnings = [
          AppLocalizations.of(context).getTranslate('invalid_credentials')
        ];
        showWarnings();
      }
    } else {
      showWarnings();
    }

    setState(() {
      warnings = msgs;
      loading = false;
    });
  }

  Future<Map<String, dynamic>?> performLogin(String email, String password) async {
    final url = Uri.parse('https://api.eskanist.com/public/api/login');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final success = responseBody['success'] as bool;
      if (success) {
        // Login successful, return the response body
        return responseBody;
      } else {
        // Login failed, handle the error message
        final msg = responseBody['msg'] as String;
        print('Login failed: $msg');
      }
    } else {
      // Handle error cases here
      print('Error: ${response.statusCode}');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    settings = context.read<SettingsCubit>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading ? const Center(child: CircularProgressIndicator()) : Column(
            children:[
              Text(AppLocalizations.of(context).getTranslate('mail')),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => setState(() {
                  email = value;
                }),
              ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).getTranslate('passwd')),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                onChanged: (value) => setState(() {
                  password = value;
                }),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => login(),
                child: Text(AppLocalizations.of(context).getTranslate('login')),
              )
            ]
        ),
      ),
    );
  }
}