import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import '../../../data/models/infographic_model.dart';
import '../../../data/services/ppt_service.dart';

class InfographicViewerController extends GetxController {
  late InfographicModel infographic;
  InAppWebViewController? webViewController;
  final ScreenshotController screenshotController = ScreenshotController();
  
  // Multiple screenshot controllers for each section
  final List<ScreenshotController> sectionScreenshotControllers = [];
  final sectionScreenshots = <int, Uint8List>{}.obs;
  
  final isLoading = true.obs;
  final isDownloading = false.obs;
  final isDownloadingPPT = false.obs;
  final isEditing = false.obs;
  final editingText = ''.obs;
  final editingElementId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    infographic = Get.arguments as InfographicModel;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    
    // Add JavaScript handler for text editing
    controller.addJavaScriptHandler(
      handlerName: 'onTextClick',
      callback: (args) {
        if (args.isNotEmpty) {
          onTextElementClicked(Map<String, dynamic>.from(args[0]));
        }
      },
    );
  }

  void onLoadStop() {
    isLoading.value = false;
    _injectEditingScript();
  }

  void _injectEditingScript() {
    const script = '''
      function makeElementsEditable() {
        const editableSelectors = [
          '.title', '.subtitle', '.heading', '.text', '.fact', '.statistic',
          'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', '.content', '.description'
        ];
        
        editableSelectors.forEach(selector => {
          const elements = document.querySelectorAll(selector);
          elements.forEach((element, index) => {
            if (!element.id) {
              element.id = selector.replace('.', '') + '_' + index;
            }
            element.style.cursor = 'pointer';
            element.addEventListener('click', function(e) {
              e.preventDefault();
              window.flutter_inappwebview.callHandler('onTextClick', {
                id: element.id,
                text: element.textContent || element.innerText
              });
            });
          });
        });
      }
      
      function updateElementText(id, newText) {
        const element = document.getElementById(id);
        if (element) {
          element.textContent = newText;
        }
      }
      
      makeElementsEditable();
    ''';
    
    webViewController?.evaluateJavascript(source: script);
  }

  void onTextElementClicked(Map<String, dynamic> data) {
    editingElementId.value = data['id'];
    editingText.value = data['text'];
    isEditing.value = true;
  }

  void updateTextElement() {
    if (editingElementId.value.isNotEmpty && editingText.value.isNotEmpty) {
      webViewController?.evaluateJavascript(
        source: "updateElementText('${editingElementId.value}', '${editingText.value.replaceAll("'", "\\'")}');",
      );
    }
    cancelEditing();
  }

  void cancelEditing() {
    isEditing.value = false;
    editingText.value = '';
    editingElementId.value = '';
  }

  Future<void> downloadAsPng() async {
    try {
      isDownloading.value = true;

      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download the image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }

      // Capture screenshot
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'infographic_$timestamp.png';
      final file = File('${directory.path}/$filename');

      // Save file
      await file.writeAsBytes(imageBytes);

      Get.snackbar(
        'Success',
        'Infographic saved to ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadAsPPT() async {
    try {
      isDownloadingPPT.value = true;
      
      // Show progress message
      Get.snackbar(
        "Generating PPT",
        "Capturing section screenshots and creating PowerPoint presentation...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: Duration(seconds: 2),
      );

      // Capture screenshots of each section
      await _captureSectionScreenshots();

      // Generate PowerPoint with screenshots
      final filePath = await PPTService.generatePPTWithScreenshots(infographic, sectionScreenshots);
      
      if (filePath != null) {
        Get.snackbar(
          'Success',
          'PowerPoint presentation saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 4),
        );
      } else {
        throw Exception('Failed to generate PowerPoint presentation');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PowerPoint: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isDownloadingPPT.value = false;
    }
  }

  Future<void> _captureSectionScreenshots() async {
    try {
      sectionScreenshots.clear();
      
      // Get the number of sections from the HTML
      final sectionCount = _countSectionsInHTML();
      print('📸 Found $sectionCount sections in HTML');
      
      if (sectionCount == 0) {
        // Fallback: capture the entire infographic as one section
        final fullScreenshot = await screenshotController.capture();
        if (fullScreenshot != null) {
          sectionScreenshots[0] = fullScreenshot;
          print('📸 Captured full infographic as single section');
        }
        return;
      }
      
      // Capture each section individually by scrolling and taking screenshots
      await _captureEachSectionIndividually(sectionCount);
      
      print('📸 Successfully captured ${sectionScreenshots.length} section screenshots');
    } catch (e) {
      print('❌ Error capturing section screenshots: $e');
      throw Exception('Failed to capture section screenshots: $e');
    }
  }

  Future<void> _captureEachSectionIndividually(int sectionCount) async {
    try {
      if (webViewController == null) {
        throw Exception('WebView controller not available');
      }

      // Start from the top
      await webViewController!.scrollTo(x: 0, y: 0);
      await Future.delayed(Duration(milliseconds: 1000));

      for (int i = 0; i < sectionCount; i++) {
        try {
          print('📸 Capturing section $i...');
          
          // Scroll to the specific section
          await _scrollToSection(i);
          await Future.delayed(Duration(milliseconds: 800));
          
          // Wait for content to load
          await Future.delayed(Duration(milliseconds: 500));
          
          // Capture the current view
          final screenshot = await screenshotController.capture();
          if (screenshot != null && screenshot.length > 0) {
            sectionScreenshots[i] = screenshot;
            print('✅ Successfully captured section $i (${screenshot.length} bytes)');
          } else {
            print('❌ Failed to capture section $i - screenshot is null or empty');
            // Try capturing the full view as fallback
            final fullScreenshot = await screenshotController.capture();
            if (fullScreenshot != null && fullScreenshot.length > 0) {
              sectionScreenshots[i] = fullScreenshot;
              print('📸 Used full screenshot as fallback for section $i');
            }
          }
        } catch (e) {
          print('❌ Failed to capture section $i: $e');
          // Continue with next section
        }
      }
      
      // Ensure we have at least one screenshot
      if (sectionScreenshots.isEmpty) {
        print('📸 No screenshots captured, using full screenshot as fallback');
        final fullScreenshot = await screenshotController.capture();
        if (fullScreenshot != null && fullScreenshot.length > 0) {
          sectionScreenshots[0] = fullScreenshot;
        }
      }
    } catch (e) {
      print('❌ Error in section capture: $e');
      throw Exception('Failed to capture sections: $e');
    }
  }

  Future<void> _scrollToSection(int sectionIndex) async {
    try {
      if (webViewController == null) return;
      
      // Calculate scroll position based on section index
      // Each section is 56.25vw high, so we need to scroll by sectionIndex * 56.25vw
      // Convert to pixels (assuming 1vw = 3.75px on average mobile screen)
      final scrollY = (sectionIndex * 56.25 * 3.75).round();
      
      print('📸 Scrolling to section $sectionIndex at position $scrollY');
      await webViewController!.scrollTo(x: 0, y: scrollY);
      
      // Wait for scroll to complete
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print('❌ Error scrolling to section $sectionIndex: $e');
    }
  }

  int _countSectionsInHTML() {
    // Count sections with class "section-16-9" in the HTML
    final sectionMatches = RegExp(r'<[^>]*class="[^"]*section-16-9[^"]*"[^>]*>', dotAll: true)
        .allMatches(infographic.htmlCode);
    return sectionMatches.length;
  }

  void regenerateInfographic() {
    Get.back();
  }
}
