import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/favorites_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    FavoritesScreen(),
    MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          setState(() {

            _selectedIndex = index;

          });

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Messages",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}