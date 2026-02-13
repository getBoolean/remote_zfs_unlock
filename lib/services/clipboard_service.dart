import 'package:super_clipboard/super_clipboard.dart';

class ClipboardService {
  Future<bool> copyPlainText(String value) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return false;
    }
    final item = DataWriterItem();
    item.add(Formats.plainText(value));
    await clipboard.write([item]);
    return true;
  }
}
