import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with wave-like shape
          Positioned.fill(
            child: CustomPaint(
              painter: _WavePainter(),
              child: Container(),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  const SizedBox(height: 40),
                  
                  // App Title
                  const Text(
                    'Imagine X',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  const Text(
                    'Visualize your ideas in seconds',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF718096),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Prompt Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                          offset: const Offset(0, 8),
                  ),
                ],
              ),
                    child: Obx(() => TextField(
                      controller: controller.promptController,
                      enabled: !controller.isLoading.value,
                      decoration: InputDecoration(
                        hintText: 'What you want to visualize...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        suffixIcon: Obx(() => GestureDetector(
                          onTap: controller.isLoading.value ? null : () {
                            controller.generateInfographic();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        )),
                      ),
                      onChanged: (value) => controller.clearError(),
                      onSubmitted: (value) => controller.generateInfographic(),
                    )),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Example Topics
                  const Text(
                    'Example Topics:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tags Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildTag('5G Technology'),
                      _buildTag('Dog Breeds'),
                      _buildTag('Public Issues'),
                      _buildTag('Learning Plans'),
                      _buildTag('Office Culture'),
                      _buildTag('Fan Pages'),
                      _buildTag('Freelance Work'),
                      _buildTag('Objectives'),
                      _buildTag('Furniture'),
                      _buildTag('Climate Change'),
                      _buildTag('AI Trends'),
                    ],
                  ),
                  
                  // Footer - Hide when keyboard is visible
                  if (!isKeyboardVisible) ...[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    const Column(
                      children: [
                        Text(
                          'Innovation starts where imagination ends.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'AI that sees beyond limits ✨',
                          style: TextStyle(
                        fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ] else
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          

          // Error Message (if any)
                  Obx(() => controller.errorMessage.value.isNotEmpty
              ? Positioned(
                  top: 100,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
  
  Widget _buildTag(String text) {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value ? null : () {
        controller.promptController.text = text;
        // Don't auto-generate, let user press Enter or click arrow
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
                ),
              ],
            ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: controller.isLoading.value 
                ? const Color(0xFF2D3748).withValues(alpha: 0.5)
                : const Color(0xFF2D3748),
          ),
        ),
      ),
    ));
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create a wave-like shape starting from the left
    path.moveTo(0, size.height * 0.3);
    
    // First curve
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.2,
      size.width * 0.4, size.height * 0.3,
    );
    
    // Second curve
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.4,
      size.width * 0.8, size.height * 0.3,
    );
    
    // Final curve to bottom right
    path.quadraticBezierTo(
      size.width, size.height * 0.2,
      size.width, size.height,
    );
    
    // Complete the shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}