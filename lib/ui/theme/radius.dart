import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 26;
  static const double xxl = 32;
  static const double pill = 999;

  static const BorderRadius borderRadiusXs =
      BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXxl =
      BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(pill));
}
