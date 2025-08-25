import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';
import 'welcome_journey_screen.dart';

class IntroVideoScreen extends StatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
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
            // Hide loading after a short delay to ensure video is ready
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
          },
        ),
      )
      ..loadHtmlString(_getVimeoHtml());
  }

  String _getVimeoHtml() {
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
              iframe { 
                  width: 100%; 
                  height: 100%; 
                  border: none;
              }
          </style>
      </head>
      <body>
          <iframe src="https://player.vimeo.com/video/${AppConfig.introVideoId}?h=92add14ea5&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" 
                  frameborder="0" 
                  allow="autoplay; fullscreen; picture-in-picture" 
                  allowfullscreen>
          </iframe>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(AppStrings.introVideoTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Video WebView
          WebViewWidget(controller: _webViewController),
          
          // Loading indicator - only show briefly, don't cover video
          if (_isLoading)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          
          // Instructions and button at the top - positioned to be fully visible
          SafeArea(
            child: Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dale play!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Si todavía no has visto el video de introducción, es importante que lo hagas... dura un minuto, literalmente.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Continue button - made smaller and more compact
                    SizedBox(
                      width: 160,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const WelcomeJourneyScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: Text(
                          'Ya vi el video, continuar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


