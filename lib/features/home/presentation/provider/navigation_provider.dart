import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentTab = 0;

  int get currentTab => _currentTab;

  void changeTab(int index) {
    _currentTab = index;
    notifyListeners();
  }
}
