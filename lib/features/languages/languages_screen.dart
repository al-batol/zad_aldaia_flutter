import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:zad_aldaia/core/helpers/language.dart';
import 'package:zad_aldaia/core/routing/routes.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Select Language')),
      body: GridView.count(
        crossAxisCount: 2,
        children:
            Lang.values
                .map(
                  (e) => Card(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/flags/$e.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                          ),
                        ),
                        child: Center(child: Text(e.toUpperCase(), style: TextStyle(color: Colors.white))),
                      ),
                      onTap: () async {
                        await Lang.set(e);
                        Navigator.of(context).pushNamed(MyRoutes.homeScreen);
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
