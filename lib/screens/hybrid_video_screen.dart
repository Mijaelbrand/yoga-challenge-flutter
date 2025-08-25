import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class HybridVideoScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String phoneNumber;
  final String token;

  const HybridVideoScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.phoneNumber,
    required this.token,
  });

  @override
  State<HybridVideoScreen> createState() => _HybridVideoScreenState();
}

class _HybridVideoScreenState extends State<HybridVideoScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final hybridUrl = _buildHybridVideoUrl();
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Video loading error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(hybridUrl));
    
    debugPrint('Loading hybrid video URL: $hybridUrl');
  }

  String _buildHybridVideoUrl() {
    // Match Android's ManyChatIntegration.buildHybridVideoUrl exactly:
    // HYBRID_BASE_URL/?video=day1&token=abc&phone=123
    final encodedPhone = widget.phoneNumber.replaceAll('+', '%2B');
    return '${AppConfig.videoBaseUrl}?video=${widget.videoId}&token=${widget.token}&phone=$encodedPhone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Video WebView - matches Android's VideoPlayerActivity
          WebViewWidget(controller: _webViewController),
          
          // Loading indicator - matches Android
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}