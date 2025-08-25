import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoId;
  final String title;

  const VideoPlayerWidget({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
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
        ),
      )
      ..loadHtmlString(_getVideoHtml());
  }

  String _getVideoHtml() {
    // For now, we'll use a placeholder video
    // In the real implementation, this would load the actual video based on videoId
    return '''
      <!DOCTYPE html>
      <html>
      <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
              * { margin: 0; padding: 0; }
              html, body { 
                  width: 100%; 
                  height: 100%; 
                  background: #000;
              }
              .video-container {
                  width: 100%;
                  height: 100%;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  color: white;
                  font-family: Arial, sans-serif;
              }
              .placeholder {
                  text-align: center;
                  padding: 20px;
              }
          </style>
      </head>
      <body>
          <div class="video-container">
              <div class="placeholder">
                  <h2>Video: ${widget.videoId}</h2>
                  <p>Este video se cargará desde el sistema híbrido</p>
                  <p>ID: ${widget.videoId}</p>
              </div>
          </div>
      </body>
      </html>
    ''';
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
      ),
      body: Stack(
        children: [
          // Video WebView
          WebViewWidget(controller: _webViewController),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando video...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
