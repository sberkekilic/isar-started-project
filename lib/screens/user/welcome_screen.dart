import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../localizations/localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = context.watch<SettingsCubit>().state.userLoggedIn;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (!isUserLoggedIn)
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push('/login');
                },
                child: Text(AppLocalizations.of(context).getTranslate('login')),
              ),
            if (!isUserLoggedIn)
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push('/register');
                },
                child: Text(AppLocalizations.of(context).getTranslate('register')),
              ),
            if (!isUserLoggedIn)
              TextButton(
                onPressed: () {
                  GoRouter.of(context).push('/news');
                },
                child: Text(AppLocalizations.of(context).getTranslate('continue_no_user')),
              ),
          ],
        ),
      ),
    );
  }
}
