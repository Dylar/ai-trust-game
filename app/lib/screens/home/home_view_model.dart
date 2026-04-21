import 'package:flutter/foundation.dart';

import 'home_screen_state.dart';

class HomeViewModel {
  HomeViewModel() : state = ValueNotifier(HomeScreenState.initial());
  final ValueNotifier<HomeScreenState> state;

  void dispose() {
    state.dispose();
  }
}
