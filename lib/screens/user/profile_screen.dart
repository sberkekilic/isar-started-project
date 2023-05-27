import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../blocs/settings/settings_cubit.dart';
import '../../localizations/localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SettingsCubit settings;

  askLogout() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).getTranslate("logout")),
        content:
            Text(AppLocalizations.of(context).getTranslate("logout_confirm")),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(AppLocalizations.of(context).getTranslate("yes")),
            onPressed: () {
              settings.userLogout();
              Navigator.of(context).pop();
              GoRouter.of(context).replace('/welcome');
            },
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).getTranslate("no")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    settings = context.read<SettingsCubit>();
    super.initState();
    if (settings.state.userLoggedIn) {
    } else {
      GoRouter.of(context).replace('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).getTranslate('profile')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Geri butonuna basıldığında yapılacak işlemler
              GoRouter.of(context).push('/news'); // Anasayfaya yönlendirme
            },
          ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://www.technopat.net/sosyal/data/avatars/o/418/418454.jpg?1611149721"), // Replace with the URL of the user's avatar image
            ),
            SizedBox(height: 16),
            Text(
              "${AppLocalizations.of(context).getTranslate('name')}: ${settings.state.userInfo[0]}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "${AppLocalizations.of(context).getTranslate('mail')}: ${settings.state.userInfo[1]}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push('/tickets');
                  },
                  child: Text(
                    "  ${AppLocalizations.of(context).getTranslate('support')}  ",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: 300,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    title: Text(
                      "${AppLocalizations.of(context).getTranslate('settings')}",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      GoRouter.of(context).push('/settings');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    title: Text(
                      "${AppLocalizations.of(context).getTranslate('logout')}",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      askLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
