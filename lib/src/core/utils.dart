import 'dart:convert';

import 'package:tron_energy_wallet_core/src/core/core.dart';

/// Проверка и подготовка сообщения для отправки через OP_RETURN в сети BTC
String? convertMessageForOpReturn(String? message) {
  if (message == null || message.isEmpty) return null;

  // Кодируем сообщение в байты (UTF-8)
  var messageBytes = utf8.encode(message);

  // Проверяем длину и обрезаем, если больше 80 байт
  if (messageBytes.length > 80) {
    messageBytes = messageBytes.sublist(0, 80);
    InAppLogger.instance.logInfoMessage(
        'convertMessageForOpReturn', 'Сообщение обрезано до 80 байт');
  }
  return utf8.decode(messageBytes, allowMalformed: true);
}
