import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../features/pro/domain/trigger_context.dart';
import '../../../features/pro/presentation/smart_paywall.dart';
import '../../../main.dart';
import 'bella_chat_pdf_builder.dart';
import 'chat_message.dart';

/// Orchestrates the Bella chat PDF export.
///
/// Pro users get the PDF share sheet directly.
/// Free users see the paywall with [TriggerContext.bellaChatExport].
class BellaChatExporter {
  BellaChatExporter._();

  static Future<void> export({
    required List<ChatMessage> messages,
    required bool isPro,
  }) async {
    if (!isPro) {
      final navContext = OperationsbegleiterApp
          .appNavigatorKey?.currentState?.overlay?.context;
      if (navContext != null) {
        SmartPaywall.trigger(
          context: navContext,
          triggerContext: TriggerContext.bellaChatExport,
        );
      }
      return;
    }

    final bytes = await BellaChatPdfBuilder.build(messages);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Bella_Chat_$date.pdf',
    );
  }
}
