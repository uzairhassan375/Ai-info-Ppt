import 'dart:io';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../models/infographic_model.dart';
import 'package:flutter/material.dart';

class PPTService {
  /// Generate PowerPoint presentation from infographic data
  static Future<String?> generatePPT(InfographicModel infographic) async {
    try {
      print('🔍 PPT: Starting PowerPoint generation...');
      
      // Create new PowerPoint presentation
      final pres = FlutterPowerPoint();
      
      // Parse HTML content to extract structured data
      final slideData = _parseInfographicData(infographic.htmlCode);
      
      // Add title slide
      _addTitleSlide(pres, infographic.prompt, slideData);
      
      // Add content slides based on parsed data
      _addContentSlides(pres, slideData);
      
      // Add summary slide
      _addSummarySlide(pres, slideData);
      
      // Generate PowerPoint bytes
      final bytes = await pres.save();
      print('🔍 PPT: PowerPoint generated successfully, size: ${bytes?.length ?? 0} bytes');
      
      // Save to file
      if (bytes != null) {
        final filePath = await _savePPTFile(bytes, infographic.prompt);
        return filePath;
      } else {
        throw Exception('Failed to generate PowerPoint bytes');
      }
    } catch (e) {
      print('🔍 PPT: Error generating PowerPoint: $e');
      Get.snackbar(
        "Error",
        "Failed to generate PowerPoint: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return null;
    }
  }
  
  /// Parse HTML content to extract structured data for slides
  static Map<String, dynamic> _parseInfographicData(String htmlContent) {
    final data = <String, dynamic>{
      'title': '',
      'subtitle': '',
      'sections': <Map<String, dynamic>>[],
      'statistics': <String>[],
      'charts': <Map<String, dynamic>>[],
    };
    
    try {
      // Extract title
      final titleMatch = RegExp(r'<h1[^>]*class="title"[^>]*>(.*?)</h1>', dotAll: true).firstMatch(htmlContent);
      if (titleMatch != null) {
        data['title'] = _cleanHtmlText(titleMatch.group(1) ?? '');
      }
      
      // Extract subtitle
      final subtitleMatch = RegExp(r'<p[^>]*class="subtitle"[^>]*>(.*?)</p>', dotAll: true).firstMatch(htmlContent);
      if (subtitleMatch != null) {
        data['subtitle'] = _cleanHtmlText(subtitleMatch.group(1) ?? '');
      }
      
      // Extract sections
      final sectionMatches = RegExp(r'<section[^>]*class="([^"]*)"[^>]*>(.*?)</section>', dotAll: true).allMatches(htmlContent);
      for (final match in sectionMatches) {
        final className = match.group(1) ?? '';
        final content = match.group(2) ?? '';
        
        if (className.contains('statistics') || className.contains('data')) {
          _extractStatistics(content, data);
        } else if (className.contains('chart') || className.contains('visualization')) {
          _extractCharts(content, data);
        } else {
          _extractGeneralSection(content, data, className);
        }
      }
      
      // Extract standalone statistics
      final statMatches = RegExp(r'<div[^>]*class="[^"]*stat[^"]*"[^>]*>(.*?)</div>', dotAll: true).allMatches(htmlContent);
      for (final match in statMatches) {
        final statText = _cleanHtmlText(match.group(1) ?? '');
        if (statText.isNotEmpty && !data['statistics'].contains(statText)) {
          data['statistics'].add(statText);
        }
      }
      
      print('🔍 PPT: Parsed data - Title: ${data['title']}, Sections: ${data['sections'].length}, Stats: ${data['statistics'].length}');
      
    } catch (e) {
      print('🔍 PPT: Error parsing HTML content: $e');
    }
    
    return data;
  }
  
  /// Clean HTML text by removing tags and entities
  static String _cleanHtmlText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
  
  /// Extract statistics from HTML content
  static void _extractStatistics(String content, Map<String, dynamic> data) {
    final statMatches = RegExp(r'<div[^>]*class="[^"]*stat[^"]*"[^>]*>(.*?)</div>', dotAll: true).allMatches(content);
    for (final match in statMatches) {
      final statText = _cleanHtmlText(match.group(1) ?? '');
      if (statText.isNotEmpty && !data['statistics'].contains(statText)) {
        data['statistics'].add(statText);
      }
    }
    
    // Also extract percentage and number patterns
    final percentageMatches = RegExp(r'\d+\.?\d*%').allMatches(content);
    for (final match in percentageMatches) {
      final percentage = match.group(0) ?? '';
      if (!data['statistics'].contains(percentage)) {
        data['statistics'].add(percentage);
      }
    }
  }
  
  /// Extract chart data from HTML content
  static void _extractCharts(String content, Map<String, dynamic> data) {
    final chartData = <String, dynamic>{
      'title': '',
      'data': <String>[],
    };
    
    // Extract chart title
    final titleMatch = RegExp(r'<h[2-4][^>]*>(.*?)</h[2-4]>', dotAll: true).firstMatch(content);
    if (titleMatch != null) {
      chartData['title'] = _cleanHtmlText(titleMatch.group(1) ?? '');
    }
    
    // Extract chart data points
    final dataMatches = RegExp(r'<div[^>]*class="[^"]*data[^"]*"[^>]*>(.*?)</div>', dotAll: true).allMatches(content);
    for (final match in dataMatches) {
      final dataText = _cleanHtmlText(match.group(1) ?? '');
      if (dataText.isNotEmpty) {
        chartData['data'].add(dataText);
      }
    }
    
    if (chartData['title'].isNotEmpty || chartData['data'].isNotEmpty) {
      data['charts'].add(chartData);
    }
  }
  
  /// Extract general section data
  static void _extractGeneralSection(String content, Map<String, dynamic> data, String className) {
    final sectionData = <String, dynamic>{
      'title': '',
      'content': <String>[],
      'className': className,
    };
    
    // Extract section title
    final titleMatch = RegExp(r'<h[2-4][^>]*>(.*?)</h[2-4]>', dotAll: true).firstMatch(content);
    if (titleMatch != null) {
      sectionData['title'] = _cleanHtmlText(titleMatch.group(1) ?? '');
    }
    
    // Extract section content
    final contentMatches = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).allMatches(content);
    for (final match in contentMatches) {
      final contentText = _cleanHtmlText(match.group(1) ?? '');
      if (contentText.isNotEmpty && contentText.length > 10) {
        sectionData['content'].add(contentText);
      }
    }
    
    if (sectionData['title'].isNotEmpty || sectionData['content'].isNotEmpty) {
      data['sections'].add(sectionData);
    }
  }
  
  /// Add title slide to presentation
  static void _addTitleSlide(FlutterPowerPoint pres, String prompt, Map<String, dynamic> slideData) {
    final title = slideData['title']?.toString().isNotEmpty == true 
        ? slideData['title'].toString() 
        : prompt;
    final subtitle = slideData['subtitle']?.toString().isNotEmpty == true 
        ? slideData['subtitle'].toString() 
        : 'Generated Infographic';
    
    pres.addTitleSlide(
      title: title.toTextValue(),
      author: subtitle.toTextValue(),
    );
    
    print('🔍 PPT: Added title slide - $title');
  }
  
  /// Add content slides based on parsed data
  static void _addContentSlides(FlutterPowerPoint pres, Map<String, dynamic> slideData) {
    // Add statistics slide if we have statistics
    if (slideData['statistics']?.isNotEmpty == true) {
      final stats = (slideData['statistics'] as List).take(8).map((e) => e.toString()).toList();
      pres.addTitleAndBulletsSlide(
        title: 'Key Statistics'.toTextValue(),
        subtitle: 'Important Data Points'.toTextValue(),
        bullets: stats.map((e) => e.toTextValue()).toList(),
      );
      print('🔍 PPT: Added statistics slide with ${stats.length} items');
    }
    
    // Add section slides
    final sections = slideData['sections'] as List<Map<String, dynamic>>;
    for (int i = 0; i < sections.length && i < 5; i++) {
      final section = sections[i];
      final title = section['title']?.toString() ?? 'Section ${i + 1}';
      final content = section['content'] as List<String>;
      
      if (content.isNotEmpty) {
        final bullets = content.take(6).map((e) => e.toTextValue()).toList();
        pres.addTitleAndBulletsSlide(
          title: title.toTextValue(),
          subtitle: 'Detailed Information'.toTextValue(),
          bullets: bullets,
        );
        print('🔍 PPT: Added section slide - $title with ${bullets.length} bullets');
      }
    }
    
    // Add chart slides
    final charts = slideData['charts'] as List<Map<String, dynamic>>;
    for (int i = 0; i < charts.length && i < 3; i++) {
      final chart = charts[i];
      final title = chart['title']?.toString() ?? 'Chart ${i + 1}';
      final data = chart['data'] as List<String>;
      
      if (data.isNotEmpty) {
        final bullets = data.take(6).map((e) => e.toTextValue()).toList();
        pres.addTitleAndBulletsSlide(
          title: title.toTextValue(),
          subtitle: 'Data Visualization'.toTextValue(),
          bullets: bullets,
        );
        print('🔍 PPT: Added chart slide - $title with ${bullets.length} data points');
      }
    }
  }
  
  /// Add summary slide
  static void _addSummarySlide(FlutterPowerPoint pres, Map<String, dynamic> slideData) {
    final summaryPoints = <String>[];
    
    // Add key statistics as summary points
    final stats = slideData['statistics'] as List<String>;
    if (stats.isNotEmpty) {
      summaryPoints.addAll(stats.take(3).map((e) => '📊 $e'));
    }
    
    // Add section highlights
    final sections = slideData['sections'] as List<Map<String, dynamic>>;
    if (sections.isNotEmpty) {
      summaryPoints.add('📋 ${sections.length} detailed sections covered');
    }
    
    // Add chart highlights
    final charts = slideData['charts'] as List<Map<String, dynamic>>;
    if (charts.isNotEmpty) {
      summaryPoints.add('📈 ${charts.length} data visualizations included');
    }
    
    if (summaryPoints.isEmpty) {
      summaryPoints.addAll([
        '📊 Comprehensive data analysis',
        '📋 Detailed information breakdown',
        '📈 Visual data representations',
      ]);
    }
    
    pres.addTitleAndBulletsSlide(
      title: 'Summary'.toTextValue(),
      subtitle: 'Key Takeaways'.toTextValue(),
      bullets: summaryPoints.take(6).map((e) => e.toTextValue()).toList(),
    );
    
    print('🔍 PPT: Added summary slide with ${summaryPoints.length} points');
  }
  
  /// Save PPT file to device storage
  static Future<String> _savePPTFile(List<int> bytes, String prompt) async {
    try {
      // No special permissions needed for app documents directory
      
      // Get directory for saving files
      Directory directory;
      if (Platform.isAndroid) {
        // For Android, use app documents directory which doesn't require special permissions
        directory = await getApplicationDocumentsDirectory();
        
        // Create a subdirectory for PowerPoint files
        final pptDir = Directory('${directory.path}/PowerPoint');
        if (!await pptDir.exists()) {
          await pptDir.create(recursive: true);
        }
        directory = pptDir;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Create filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safePrompt = prompt.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final filename = 'infographic_${safePrompt}_$timestamp.pptx';
      final file = File('${directory.path}/$filename');
      
      // Write file
      await file.writeAsBytes(bytes);
      
      print('🔍 PPT: File saved to ${file.path}');
      
      // Get user-friendly location info
      final locationInfo = Platform.isAndroid 
          ? "App Documents/PowerPoint folder"
          : "Documents folder";
      
      // Show success message with share option
      Get.snackbar(
        "PowerPoint Generated Successfully! 🎉",
        "File: $filename\nSaved to: $locationInfo\n\nTap the Share button to share the file",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => _sharePPTFile(file.path, filename),
          child: Text(
            "Share",
            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      );
      
      return file.path;
    } catch (e) {
      print('🔍 PPT: Error saving file: $e');
      rethrow;
    }
  }
  
  /// Share PPT file
  static Future<void> _sharePPTFile(String filePath, String filename) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Check out this PowerPoint presentation: $filename',
          subject: 'PowerPoint Presentation - $filename',
        );
        print('🔍 PPT: File shared successfully');
      } else {
        Get.snackbar(
          "Error",
          "File not found. Please try generating the PowerPoint again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      print('🔍 PPT: Error sharing file: $e');
      Get.snackbar(
        "Error",
        "Failed to share file: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
  
  /// Get the save location information
  static Future<String> getSaveLocationInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pptDir = Directory('${directory.path}/PowerPoint');
      return pptDir.path;
    } catch (e) {
      return 'Unknown location';
    }
  }
  
  /// Check if PPT generation is supported
  static bool get isSupported => true;
}
