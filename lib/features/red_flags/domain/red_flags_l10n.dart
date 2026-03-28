import '../../../l10n/app_localizations.dart';
import 'red_flag.dart';

/// Localized label for a [RedFlagSeverity] colour level.
String localizedRedFlagSeverity(AppLocalizations l, RedFlagSeverity s) {
  return switch (s) {
    RedFlagSeverity.green  => l.gruen,
    RedFlagSeverity.yellow => l.rfSeverityYellow,
    RedFlagSeverity.orange => l.rfSeverityOrange,
    RedFlagSeverity.red    => l.rfSeverityRed,
  };
}

/// Localized short title for a [RedFlagSeverity] (used in status banner).
String localizedSeverityTitle(AppLocalizations l, RedFlagSeverity s) {
  return switch (s) {
    RedFlagSeverity.green  => l.rfSeverityTitleGreen,
    RedFlagSeverity.yellow => l.rfSeverityTitleYellow,
    RedFlagSeverity.orange => l.rfSeverityTitleOrange,
    RedFlagSeverity.red    => l.rfSeverityTitleRed,
  };
}

/// Localized description for a [RedFlagSeverity].
String localizedSeverityDesc(AppLocalizations l, RedFlagSeverity s) {
  return switch (s) {
    RedFlagSeverity.green  => l.rfSeverityDescGreen,
    RedFlagSeverity.yellow => l.rfSeverityDescYellow,
    RedFlagSeverity.orange => l.rfSeverityDescOrange,
    RedFlagSeverity.red    => l.rfSeverityDescRed,
  };
}

/// Localized label for a [RedFlagStatus].
String localizedRedFlagStatus(AppLocalizations l, RedFlagStatus s) {
  return switch (s) {
    RedFlagStatus.open         => l.rfStatusOpen,
    RedFlagStatus.acknowledged => l.rfStatusAcknowledged,
    RedFlagStatus.monitoring   => l.rfStatusMonitoring,
    RedFlagStatus.escalated    => l.rfStatusEscalated,
    RedFlagStatus.resolved     => l.rfStatusResolved,
  };
}

/// Localized label for a [RedFlagSource].
String localizedRedFlagSource(AppLocalizations l, RedFlagSource s) {
  return switch (s) {
    RedFlagSource.warningCheck => l.rfSourceWarningCheck,
    RedFlagSource.pain         => l.rfSourcePain,
    RedFlagSource.vitals       => l.rfSourceVitals,
    RedFlagSource.observation  => l.rfSourceObservation,
    RedFlagSource.wound        => l.rfSourceWound,
    RedFlagSource.timeline     => l.rfSourceTimeline,
    RedFlagSource.manual       => l.rfSourceManual,
    RedFlagSource.symptomCheck => l.rfSourceSymptomCheck,
  };
}
