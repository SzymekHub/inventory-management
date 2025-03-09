import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // Singleton pattern
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();

  // Check if NFC is available on the device
  Future<bool> isNfcAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // Start NFC session and read tag data
  Future<Map<String, dynamic>?> readNfcTag(BuildContext context) async {
    if (!await isNfcAvailable()) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC is not available on this device'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    Map<String, dynamic>? tagData; // Initialize here
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Try to read NDEF data from tag
            final ndefTag = Ndef.from(tag);

            if (ndefTag != null) {
              final cachedMessage = ndefTag.cachedMessage;

              if (cachedMessage != null) {
                final records = cachedMessage.records;

                if (records.isNotEmpty) {
                  // Read the first record
                  final record = records.first;
                  String payload = String.fromCharCodes(record.payload);

                  // Remove any characters before the start of the JSON
                  int jsonStartIndex =
                      payload.indexOf('{'); // Find the first '{'
                  if (jsonStartIndex != -1) {
                    payload = payload.substring(jsonStartIndex);
                  } else {
                    debugPrint(
                        'No JSON start character found in payload.'); // Debugging
                    payload = ''; // Clear the payload if no JSON start found
                  }

                  // Try to decode the JSON
                  try {
                    tagData = jsonDecode(payload);
                    debugPrint('Successfully decoded JSON: $tagData');
                  } catch (e) {
                    debugPrint('Error decoding JSON: $e');
                    debugPrint(
                        'Payload causing error: $payload'); // Debug payload
                    tagData = null; // Clear tagData if decoding fails
                  }
                }
              } else {
                debugPrint('Cached message is null.');
              }
            } else {
              debugPrint('Tag does not support NDEF.');
            }
            // --- End NDEF Reading ---

            // --- Raw Data Reading (If NDEF fails) ---
            if (tagData == null) {
              final data = tag.data;
              final tagId =
                  data['mifare']?['identifier'] ?? data['nfca']?['identifier'];
              if (tagId != null) {
                final idStr = tagId
                    .map((e) => e.toRadixString(16).padLeft(2, '0'))
                    .join('');
                tagData = {'tagId': idStr};
                debugPrint('Read tag ID from raw data: $idStr');
                debugPrint(
                    'Payload from Raw Data ${tagData.toString()}'); //Added
              } else {
                debugPrint('Could not extract tag ID from raw data.');
              }
            }
            // --- End Raw Data Reading ---

            await NfcManager.instance.stopSession();
          } catch (e) {
            debugPrint('Error during tag processing: $e');
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting NFC session: $e');
    }

    return tagData;
  }

  // Write vinyl data to NFC tag
  Future<bool> writeNfcTag(
      BuildContext context, Map<String, dynamic> vinylData) async {
    if (!await isNfcAvailable()) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC is not available on this device'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    bool success = false;

    // Show writing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Writing to NFC Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Hold your device near an NFC tag'),
            ],
          ),
        );
      },
    );

    // Start NFC session
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndefTag = Ndef.from(tag);
            if (ndefTag != null) {
              // Convert the vinyl data to JSON
              final jsonData = jsonEncode(vinylData);

              // Create NDEF message with the vinyl data
              final ndefMessage = NdefMessage([
                NdefRecord.createText(jsonData),
              ]);

              // Write the message to the tag
              await ndefTag.write(ndefMessage);
              success = true;
            } else {
              debugPrint('Tag does not support NDEF');
            }

            // Stop the NFC session
            await NfcManager.instance.stopSession();
          } catch (e) {
            debugPrint('Error writing to NFC tag: $e');
            // Stop the NFC session on error
            await NfcManager.instance.stopSession();
            // Close the dialog
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting NFC session: $e');
      // Close the dialog
    }

    return success;
  }
}
