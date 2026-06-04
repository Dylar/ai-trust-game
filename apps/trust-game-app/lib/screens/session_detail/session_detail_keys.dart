import 'package:flutter/widgets.dart';

abstract final class SessionDetailKeys {
  static const screen = Key('sessionDetail.screen');
  static const title = Key('sessionDetail.title');
  static const loadingState = Key('sessionDetail.loading');
  static const errorState = Key('sessionDetail.error');
  static const analysisSection = Key('sessionDetail.analysis');
  static const requestsSection = Key('sessionDetail.requests');

  static ValueKey<String> requestCard(String requestId) {
    return ValueKey<String>('sessionDetail.request.$requestId');
  }
}
