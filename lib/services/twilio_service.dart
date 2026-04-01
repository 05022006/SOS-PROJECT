import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {

  static final TwilioService _instance = TwilioService._internal();
  factory TwilioService() => _instance;
  TwilioService._internal();

  String get _accountSid => dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  String get _authToken => dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  String get _fromNumber => dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';

  Future<bool> sendSMS({
    required String to,
    required String message,
  }) async {
    final url = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json',
    );

    final credentials = base64Encode(
      utf8.encode('$_accountSid:$_authToken'),
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _fromNumber,
          'To': to,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        print('SMS sent to $to');
        return true;
      } else {
        print('Twilio error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to send SMS: $e');
      return false;
    }
  }

  Future<void> sendToMultiple({
    required List<String> numbers,
    required String message,
  }) async {
    for (final number in numbers) {
      await sendSMS(to: number, message: message);
    }
  }
}
