import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/infographic_model.dart';
import '../../../data/services/pdf_service.dart';

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

  Future<void> testPermissions() async {
    print('🔍 Testing permissions...');
    
    // Test storage permission
    final storageStatus = await Permission.storage.status;
    print('🔍 Storage permission status: $storageStatus');
    
    // Test photos permission
    try {
      final photosStatus = await Permission.photos.status;
      print('🔍 Photos permission status: $photosStatus');
    } catch (e) {
      print('🔍 Photos permission error: $e');
    }
    
    // Test manage external storage
    try {
      final manageStatus = await Permission.manageExternalStorage.status;
      print('🔍 Manage external storage status: $manageStatus');
    } catch (e) {
      print('🔍 Manage external storage error: $e');
    }
  }

  Future<void> _sharePDF(String filePath) async {
    try {
      print('📤 Sharing PDF: $filePath');
      
      // Check if file exists
      final file = File(filePath);
      if (!file.existsSync()) {
        Get.snackbar(
          'Error',
          'PDF file not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }
      
      // Share the PDF file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this infographic I created with AI Visualizer!',
        subject: 'AI Visualizer - ${infographic.prompt}',
      );
      
      print('📤 PDF shared successfully');
    } catch (e) {
      print('📤 Error sharing PDF: $e');
      Get.snackbar(
        'Error',
        'Failed to share PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void _showShareDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        title: const Text('PDF Generated Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your infographic PDF has been saved successfully.'),
            const SizedBox(height: 10),
            Text(
              'Location: $filePath',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            const Text('Would you like to share it?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _sharePDF(filePath);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadAsPDF() async {
    try {
      isDownloadingPPT.value = true;
      
      // Test permissions first
      await testPermissions();
      
      // Request storage permission first
      print('📄 PDF: Requesting storage permission...');
      
      // Try to request storage permission
      PermissionStatus permissionStatus = await Permission.storage.request();
      print('📄 PDF: Storage permission status: $permissionStatus');
      
      // If storage permission is denied, try photos permission (Android 13+)
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        print('📄 PDF: Trying photos permission...');
        permissionStatus = await Permission.photos.request();
        print('📄 PDF: Photos permission status: $permissionStatus');
      }
      
      // If still not granted, show dialog to user
      if (!permissionStatus.isGranted) {
        print('📄 PDF: Permission not granted, showing dialog...');
        
        // Show dialog asking user to grant permission
        final shouldContinue = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
              'This app needs storage permission to save the PDF file. Please grant permission to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        );
        
        if (shouldContinue == true) {
          // Try requesting permission again
          permissionStatus = await Permission.storage.request();
          if (!permissionStatus.isGranted) {
            permissionStatus = await Permission.photos.request();
          }
          
          if (!permissionStatus.isGranted) {
            // Show dialog to open app settings
            final openSettings = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Storage permission is required to save PDF files. Please enable it in app settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            
            if (openSettings == true) {
              await openAppSettings();
            }
            return;
          }
        } else {
          return;
        }
      }
      
      print('📄 PDF: Permission granted: $permissionStatus');
      
      // Show progress message
      Get.snackbar(
        "Generating PDF",
        "Creating PDF document from content...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: Duration(seconds: 2),
      );

      // Generate PDF directly from HTML content
      final filePath = await PDFService.generatePDFFromHTML(infographic.prompt, infographic.combinedHtml);
      
      // Show success message
        Get.snackbar(
          'Success',
        'PDF document saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 4),
        );
      
      // Also show a dialog with share option
      _showShareDialog(filePath);
    } catch (e) {
      print('📄 PDF: Error generating PDF: $e');
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
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
