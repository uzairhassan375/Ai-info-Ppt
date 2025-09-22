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
        "Creating PowerPoint presentation with perfectly aligned content...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: Duration(seconds: 2),
      );

      // Generate PowerPoint
      final filePath = await PPTService.generatePPT(infographic);
      
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

  void regenerateInfographic() {
    Get.back();
  }
}
