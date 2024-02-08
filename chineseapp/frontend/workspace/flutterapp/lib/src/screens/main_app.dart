import 'package:flutter/material.dart';
import 'package:flutterapp/src/screens/home_screen.dart';
import 'package:flutterapp/src/screens/videos_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentPageIndex = 0;
  final _navigatorKeys = [ 
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final ValueNotifier<bool> _showNavBar = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Theme( 
      data: Theme.of(context).copyWith( 
        colorScheme: Theme.of(context).colorScheme.copyWith( 
          surface: Colors.white12,
        ),
      ),
      child: Scaffold( 
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: _showNavBar, 
          builder: (context, value, child) {
            if (value) { 
              return NavigationBar( 
                onDestinationSelected: (int index) {
                  if (currentPageIndex == index) {
                    _showNavBar.value = true;
                    _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
                  }
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                indicatorColor: Theme.of(context).colorScheme.primary,
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[ 
                  NavigationDestination(selectedIcon: Icon(Icons.home), icon: Icon(Icons.home_outlined), label: 'Home'),
                  NavigationDestination(selectedIcon: Icon(Icons.play_circle_fill_rounded), icon: Icon(Icons.play_circle_outline_rounded), label: 'Videos'),
                ]
              );
            } else {
            return SizedBox.shrink();
            }
          } 
        ),
        body: Stack(
          children: <Widget>[ 
          _buildOffstageNavigator(0, HomeScreen()),
          _buildOffstageNavigator(1,VideoScreen()),
          ],
        ),
      )
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          HomeScreen(),
          VideoScreen(),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index, Widget page) {
    var routeBuilders = _routeBuilders(context, index);
    return Offstage(
      offstage: currentPageIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }
}