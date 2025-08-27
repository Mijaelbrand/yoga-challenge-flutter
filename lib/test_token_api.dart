import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'dart:convert';

class TestTokenAPI extends StatefulWidget {
  const TestTokenAPI({Key? key}) : super(key: key);

  @override
  _TestTokenAPIState createState() => _TestTokenAPIState();
}

class _TestTokenAPIState extends State<TestTokenAPI> {
  final TextEditingController _phoneController = TextEditingController(text: '7204999569');
  String _result = '';
  bool _isLoading = false;

  Future<void> _testCheckPhone() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing Check Phone API...';
    });

    try {
      final dio = Dio();
      
      // Configure for iOS SSL issues
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };

      final phone = _phoneController.text.trim();
      final encodedPhone = phone.replaceAll('+', '%2B');
      final url = 'https://akilainstitute.com/api/yoga/check-phone.php?phone=$encodedPhone';

      final response = await dio.get(url);
      
      setState(() {
        _result = '''
✅ CHECK PHONE SUCCESS!

URL: $url
Status: ${response.statusCode}

Response:
${const JsonEncoder.withIndent('  ').convert(response.data)}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ CHECK PHONE ERROR:\n$e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetToken() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing Get Token API...';
    });

    try {
      final dio = Dio();
      
      // Configure for iOS SSL issues
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };

      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final phone = _phoneController.text.trim();
      final encodedPhone = phone.replaceAll('+', '%2B');
      final url = 'https://akilainstitute.com/api/yoga/get-video-token.php?phone=$encodedPhone';

      final response = await dio.get(url);
      
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      
      setState(() {
        _result = '''
${data['success'] == true ? '✅' : '❌'} GET TOKEN ${data['success'] == true ? 'SUCCESS' : 'FAILED'}!

URL: $url
Status: ${response.statusCode}

Response:
${const JsonEncoder.withIndent('  ').convert(data)}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ GET TOKEN ERROR:\n$e';
        if (e is DioException && e.response != null) {
          _result += '\n\nResponse: ${e.response!.data}';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDiagnostic() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing Diagnostic API...';
    });

    try {
      final dio = Dio();
      
      // Configure for iOS SSL issues
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };

      final phone = _phoneController.text.trim();
      final encodedPhone = phone.replaceAll('+', '%2B');
      final url = 'https://akilainstitute.com/api/yoga/api-diagnostic.php?phone=$encodedPhone';

      final response = await dio.get(url);
      
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      
      setState(() {
        _result = '''
✅ DIAGNOSTIC SUCCESS!

URL: $url
Status: ${response.statusCode}

Diagnostic Info:
${const JsonEncoder.withIndent('  ').convert(data)}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ DIAGNOSTIC ERROR:\n$e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Token API'),
        backgroundColor: const Color(0xFF4F52BD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCheckPhone,
                  child: const Text('Check Phone'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetToken,
                  child: const Text('Get Token'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDiagnostic,
                  child: const Text('Diagnostic'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Tap a button to test the API' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this to your main app to test
class TestApiScreen extends StatelessWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TestTokenAPI();
  }
}