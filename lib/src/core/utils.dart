import 'dart:convert';

import 'package:tron_energy_wallet_core/src/core/core.dart';

/// Check and prepare a message for sending via OP_RETURN on the BTC network
String? convertMessageForOpReturn(String? message) {
  if (message == null || message.isEmpty) return null;

  // Encode the message into bytes (UTF-8)
  var messageBytes = utf8.encode(message);

  // Check length and trim if longer than 80 bytes
  if (messageBytes.length > 80) {
    messageBytes = messageBytes.sublist(0, 80);
    InAppLogger.instance.logInfoMessage(
      'convertMessageForOpReturn',
      'Сообщение обрезано до 80 байт',
    );
  }
  return utf8.decode(messageBytes, allowMalformed: true);
}
