import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ModalBackButtonDispatcher.instance.init();
  runApp(const MyApp());
}

Widget box(double size, String text, [Color color = Colors.blue]) => Hero(
      tag: text,
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: color,
          child: Align(
            child: Text(
              text,
              style: const TextStyle(inherit: false),
            ),
          ),
        ),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      theme: ThemeData(platform: TargetPlatform.iOS),
      onGenerateRoute: (settings) {
        secondPage(ctx, [Color color = Colors.white]) => ColoredBox(
              color: color,
              child: Align(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => showStackModalBottomSheet(
                        context: ctx,
                        builder: (ctx) => secondPage(ctx),
                      ),
                      child: box(100, 'modal pop up'),
                    ),
                    const SizedBox(height: 20),
                    Builder(builder: (ctx) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          ctx,
                          CupertinoPageRoute(
                            builder: (ctx) => secondPage(ctx, Colors.red),
                          ),
                        ),
                        child: box(100, 'inside navi'),
                      );
                    }),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 100,
                      height: 120,
                      child: ColoredBox(
                        color: Colors.red,
                        child: Align(
                          child: Text(
                            'text',
                            style: TextStyle(inherit: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

        return MaterialWithModalsPageRoute(
          builder: (ctx) => ColoredBox(
            color: Colors.white,
            child: Align(
              child: GestureDetector(
                onTap: () => showStackModalBottomSheet(
                  context: ctx,
                  builder: (ctx) => secondPage(ctx),
                  insideNavigator: true,
                ),
                child: box(100, 'modal pop up'),
              ),
            ),
          ),
        );
      },
    );
  }
}
