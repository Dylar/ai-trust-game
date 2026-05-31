import 'package:flutter/material.dart';

abstract final class SessionStartKeys {
  static const screen = Key('session_start.screen');
  static const title = Key('session_start.title');
  static const prepareButton = Key('session_start.prepare_button');

  static const roleGuest = Key('session_start.role.guest');
  static const roleEmployee = Key('session_start.role.employee');
  static const roleAdmin = Key('session_start.role.admin');

  static const modeEasy = Key('session_start.mode.easy');
  static const modeMedium = Key('session_start.mode.medium');
  static const modeHard = Key('session_start.mode.hard');

  static const modeEasyIndicator = Key('session_start.mode.easy.indicator');
  static const modeMediumIndicator = Key('session_start.mode.medium.indicator');
  static const modeHardIndicator = Key('session_start.mode.hard.indicator');
}
