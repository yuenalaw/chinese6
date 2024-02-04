import 'package:flutter/material.dart';
import 'package:flutterapp/src/screens/home_screen.dart';
import 'package:flutterapp/src/screens/home_screen2.dart';



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

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      bottomNavigationBar: NavigationBar( 
        onDestinationSelected: (int index) {
          if (currentPageIndex == index) {
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
      ),
      body: Stack(
        children: <Widget>[ 
        _buildOffstageNavigator(0, HomeScreen()),
        _buildOffstageNavigator(1,HomeScreen2()),
        ],
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          HomeScreen(),
          HomeScreen2(),
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