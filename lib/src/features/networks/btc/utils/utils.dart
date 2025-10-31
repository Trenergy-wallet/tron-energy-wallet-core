import 'dart:convert';

import 'package:tr_logger/tr_logger.dart';

/// Check and prepare a message for sending via OP_RETURN on the BTC network
String? convertMessageForOpReturn(String? message, [TRLogger? logger]) {
  if (message == null || message.isEmpty) return null;

  // Encode the message into bytes (UTF-8)
  var messageBytes = utf8.encode(message);

  // Check length and trim if longer than 80 bytes
  if (messageBytes.length > 80) {
    messageBytes = messageBytes.sublist(0, 80);
    (logger ?? InAppLogger()).logInfoMessage(
      'convertMessageForOpReturn',
      'The message was truncated to 80 bytes',
    );
  }
  return utf8.decode(messageBytes, allowMalformed: true);
}
