import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/settings/settings_cubit.dart';
import '../../localizations/localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsCubit settings;

  @override
  void initState() {
    settings = context.read<SettingsCubit>();
    super.initState();
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
            AppLocalizations.of(context).getTranslate('language_selection'), style: TextStyle(fontSize: 20),),
        message: Text(
            AppLocalizations.of(context).getTranslate('language_selection2')),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              settings.changeLanguage("tr");
              Navigator.pop(context);
            },
            child: const Text('Türkçe'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.changeLanguage("en");
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.changeLanguage("fr");
              Navigator.pop(context);
            },
            child: const Text('Français'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).getTranslate('cancel')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).getTranslate('settings')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Geri butonuna basıldığında yapılacak işlemler
            GoRouter.of(context).go('/news'); // Anasayfaya yönlendirme
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          InkWell(
              onTap: () {
                _showActionSheet(context);
              },
              child: Text(
                  '${AppLocalizations.of(context).getTranslate('language')} : ${settings.state.language}')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  '${AppLocalizations.of(context).getTranslate('darkMode')}: '),
              Switch(
                value: settings.state.darkMode,
                onChanged: (value) {
                  settings.changeDarkMode(value);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}