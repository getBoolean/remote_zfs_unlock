import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HexByteInputFormatter extends TextInputFormatter {
  const HexByteInputFormatter();

  static final RegExp _hexCharPattern = RegExp(r'[0-9a-fA-F]');
  static const _maxHexChars = 64;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawHex = _extractHexChars(newValue.text).toUpperCase();
    final truncatedHex = rawHex.length > _maxHexChars
        ? rawHex.substring(0, _maxHexChars)
        : rawHex;
    final formatted = _formatHexWithByteSpacing(truncatedHex);

    final selectionRawIndex = _extractHexChars(
      newValue.text.substring(0, newValue.selection.extentOffset),
    ).length.clamp(0, truncatedHex.length);
    final selectionOffset = _selectionOffsetForRawHexIndex(selectionRawIndex);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  String _extractHexChars(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      if (_hexCharPattern.hasMatch(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String _formatHexWithByteSpacing(String hex) {
    if (hex.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < hex.length; i++) {
      if (i > 0 && i.isEven) {
        buffer.write(' ');
      }
      buffer.write(hex[i]);
    }
    return buffer.toString();
  }

  int _selectionOffsetForRawHexIndex(int rawIndex) {
    if (rawIndex <= 0) {
      return 0;
    }
    return rawIndex + ((rawIndex - 1) ~/ 2);
  }
}

class KeyfileHexOrUploadField extends StatelessWidget {
  const KeyfileHexOrUploadField({
    this.controller,
    this.focusNode,
    this.onChanged,
    required this.onUploadPressed,
    required this.onClearUploadedFile,
    this.uploadFieldLabelText = 'Uploaded keyfile',
    this.emptyUploadText = 'No file selected',
    this.uploadedFileName,
    this.uploadedFileSizeBytes,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback onUploadPressed;
  final VoidCallback onClearUploadedFile;
  final String uploadFieldLabelText;
  final String emptyUploadText;
  final String? uploadedFileName;
  final int? uploadedFileSizeBytes;

  @override
  Widget build(BuildContext context) {
    final isHexInputMode =
        controller != null && focusNode != null && onChanged != null;

    if (uploadedFileName == null) {
      if (!isHexInputMode) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: uploadFieldLabelText,
            suffixIcon: IconButton(
              onPressed: onUploadPressed,
              tooltip: 'Upload keyfile',
              icon: const Icon(Icons.upload_file),
            ),
          ),
          child: Text(emptyUploadText, overflow: TextOverflow.ellipsis),
        );
      }

      return TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: GoogleFonts.robotoMono(letterSpacing: 0.6),
        onChanged: onChanged,
        inputFormatters: const [HexByteInputFormatter()],
        decoration: InputDecoration(
          labelText: 'Raw key bytes (hex)',
          hintText: 'Example: 001122... (64 hex chars)',
          helperText:
              'Type hex bytes or upload keyfile. Key must be exactly 32 bytes.',
          suffixIcon: IconButton(
            onPressed: onUploadPressed,
            tooltip: 'Upload keyfile',
            icon: const Icon(Icons.upload_file),
          ),
        ),
        minLines: 1,
        maxLines: 5,
      );
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: uploadFieldLabelText,
        helperText: '${uploadedFileSizeBytes ?? 0} bytes',
        suffixIcon: IconButton(
          onPressed: onClearUploadedFile,
          tooltip: 'Remove uploaded keyfile',
          icon: const Icon(Icons.close),
        ),
      ),
      child: Text(uploadedFileName!, overflow: TextOverflow.ellipsis),
    );
  }
}
