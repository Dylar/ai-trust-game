import 'package:flutter/widgets.dart';

abstract final class InteractionDetailKeys {
  static const screen = Key('interactionDetail.screen');
  static const title = Key('interactionDetail.title');
  static const refreshIndicator = Key('interactionDetail.refresh_indicator');
  static const loadingState = Key('interactionDetail.loading');
  static const emptyAnalysisState = Key('interactionDetail.empty_analysis');
  static const errorState = Key('interactionDetail.error');
  static const analysisSection = Key('interactionDetail.analysis');
}
