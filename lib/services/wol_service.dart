import 'dart:io';
import 'dart:typed_data';

class WolService {
  static const _wolPort = 9;

  Future<void> sendMagicPacket({
    required String macAddress,
    String? broadcastAddress,
  }) async {
    final mac = _parseMac(macAddress);
    final packet = _buildMagicPacket(mac);
    final target = broadcastAddress ?? '255.255.255.255';

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      socket.broadcastEnabled = true;
      socket.send(packet, InternetAddress(target), _wolPort);
    } finally {
      socket.close();
    }
  }

  Future<bool> isReachable(String host, int port, {Duration? timeout}) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout ?? const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } on SocketException {
      return false;
    } on Exception {
      return false;
    }
  }

  Uint8List _buildMagicPacket(List<int> mac) {
    final bytes = BytesBuilder();
    // 6 bytes of 0xFF
    for (var i = 0; i < 6; i++) {
      bytes.addByte(0xFF);
    }
    // MAC address repeated 16 times
    for (var i = 0; i < 16; i++) {
      bytes.add(mac);
    }
    return bytes.toBytes();
  }

  List<int> _parseMac(String mac) {
    final cleaned = mac.replaceAll(RegExp(r'[:\-.]'), '');
    if (cleaned.length != 12) {
      throw FormatException('Invalid MAC address: $mac');
    }
    final bytes = <int>[];
    for (var i = 0; i < 12; i += 2) {
      bytes.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
}
