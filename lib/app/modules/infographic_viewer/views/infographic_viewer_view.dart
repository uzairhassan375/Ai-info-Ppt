import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import '../controllers/infographic_viewer_controller.dart';

class InfographicViewerView extends GetView<InfographicViewerController> {
  const InfographicViewerView({super.key});

  void _showShareOptions() {
    Get.dialog(
      AlertDialog(
        title: const Text('Share Options'),
        content: const Text('Choose how you would like to share the infographic:'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              // Share as PNG
              controller.downloadAsPng();
            },
            icon: const Icon(Icons.image),
            label: const Text('Share as Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              // Share as PDF
              controller.downloadAsPDF();
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Share as PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Infographic Viewer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download, color: Colors.white),
            onSelected: (value) {
              if (value == 'png') {
                controller.downloadAsPng();
              } else if (value == 'pdf') {
                controller.downloadAsPDF();
              }
            },
            itemBuilder: (context) => [
              // PNG download option hidden
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Color(0xFF6C63FF)),
                    SizedBox(width: 8),
                    Text('Download as PDF'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: controller.regenerateInfographic,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: controller.testPermissions,
            icon: const Icon(Icons.security, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.1),
                      const Color(0xFF9C88FF).withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap any text to edit • Rich data & professional design',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF6C63FF),
                      size: 16,
                    ),
                  ],
                ),
              ),

              // WebView Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Screenshot(
                      controller: controller.screenshotController,
                      child: Stack(
                        children: [
                          InAppWebView(
                            initialData: InAppWebViewInitialData(
                              data: controller.infographic.combinedHtml,
                              mimeType: 'text/html',
                              encoding: 'utf8',
                            ),
                            initialSettings: InAppWebViewSettings(
                              transparentBackground: true,
                              supportZoom: true,
                              disableHorizontalScroll: true,
                              disableVerticalScroll: false,
                              javaScriptEnabled: true,
                              useWideViewPort: true,
                              loadWithOverviewMode: true,
                              textZoom: 100,
                            ),
                            onWebViewCreated: controller.onWebViewCreated,
                            onLoadStop: (controller, url) =>
                                this.controller.onLoadStop(),
                            onConsoleMessage: (controller, consoleMessage) {
                              print('Console: ${consoleMessage.message}');
                            },
                          ),

                          // Loading overlay
                          Obx(
                            () => controller.isLoading.value
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF6C63FF),
                                                ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Creating Your Professional Infographic...',
                                            style: TextStyle(
                                              color: Color(0xFF6C63FF),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Generating rich data, charts, and visual elements',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.regenerateInfographic,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Generate New'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[700],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Download PNG button hidden
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isDownloadingPPT.value
                                  ? null
                                  : controller.downloadAsPDF,
                              icon: controller.isDownloadingPPT.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(
                                controller.isDownloadingPPT.value
                                    ? 'Generating...'
                                    : 'Download PDF',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => ElevatedButton.icon(
                            onPressed: controller.isDownloadingPPT.value
                                ? null
                                : () => _showShareOptions(),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Text Editing Modal
          Obx(
            () => controller.isEditing.value
                ? _buildEditingModal()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingModal() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Edit Text',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.cancelEditing,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: TextEditingController(
                  text: controller.editingText.value,
                ),
                onChanged: (value) => controller.editingText.value = value,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter new text...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: controller.cancelEditing,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.updateTextElement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
