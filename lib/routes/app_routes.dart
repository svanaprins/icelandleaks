import 'package:flutter/material.dart';
import '../presentation/news_dashboard/news_dashboard.dart';
import '../presentation/anonymous_tip_submission/anonymous_tip_submission.dart';
import '../presentation/scandal_timeline/scandal_timeline.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String newsDashboard = '/news-dashboard';
  static const String anonymousTipSubmission = '/anonymous-tip-submission';
  static const String scandalTimeline = '/scandal-timeline';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const NewsDashboard(),
    newsDashboard: (context) => const NewsDashboard(),
    anonymousTipSubmission: (context) => const AnonymousTipSubmission(),
    scandalTimeline: (context) => const ScandalTimeline(),
    // TODO: Add your other routes here
  };
}
