import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../bloc/cubit/app_cubit.dart';
import '../../helpers/color.helper.dart';
import '../../helpers/db.helper.dart';
import '../../theme/colors.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/dialog/confirm.modal.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: SettingsList(
                platform: DevicePlatform.android,
                darkTheme: const SettingsThemeData(
                  settingsListBackground: Colors.transparent,
                  settingsSectionBackground: Colors.transparent
                ),
                lightTheme: const SettingsThemeData(
                    settingsListBackground: Colors.transparent,
                    settingsSectionBackground: Colors.transparent
                ),
                sections: [
                  SettingsSection(
                    title: const Text('Common'),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                        onPressed: (context){

                        },
                        leading: const Icon(Icons.currency_exchange),
                        title: const Text('Currency'),
                        value: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                          Currency? currency = CurrencyService().findByCode(state.currency!);
                          return Text(currency!.name);
                        }),
                      ),

                      SettingsTile.navigation(
                        onPressed: (context) async {
                          ConfirmModal.showConfirmDialog(
                              context, title: "Are you sure?",
                              content: const Text("After deleting data can't be recovered"),
                              onConfirm: ()async{
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                await context.read<AppCubit>().reset();
                                await resetDatabase();
                              },
                              onCancel: (){
                                Navigator.of(context).pop();
                              }
                          );
                        },
                        leading: const Icon(Icons.delete, color: ThemeColors.error,),
                        title: const Text('Reset'),
                        value: const Text("Delete all the data"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.all(8.0),
                height: 10,
                width: double.infinity,
                child: const Text(
                  "Made with ❤ by ASU students",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                  )
                ),
              ),
            ),
          ],
        )
    );
  }
}
