import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PDFService {
  static Future<String> generatePDFWithScreenshots(
    String prompt,
    Map<int, Uint8List> sectionScreenshots,
  ) async {
    print('📄 PDF: Starting PDF generation with screenshots...');
    print('📄 PDF: Processing ${sectionScreenshots.length} screenshots');

    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add title page
      _addTitlePage(pdf, prompt);

      // Add screenshot pages
      for (final entry in sectionScreenshots.entries) {
        final sectionIndex = entry.key;
        final screenshot = entry.value;
        
        print('📄 PDF: Processing section $sectionIndex with ${screenshot.length} bytes');
        
        try {
          // Convert Uint8List to PDF image
          final image = pw.MemoryImage(screenshot);
          
          // Add page with screenshot
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(20),
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Section ${sectionIndex + 1}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Image(
                          image,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
          
          print('📄 PDF: Successfully added section $sectionIndex to PDF');
        } catch (e) {
          print('📄 PDF: Error adding section $sectionIndex: $e');
          
          // Add error page
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(20),
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Section ${sectionIndex + 1}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Error loading screenshot',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Screenshot size: ${screenshot.length} bytes',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          );
        }
      }

      // Save PDF
      final pdfBytes = await pdf.save();
      print('📄 PDF: PDF generated successfully, size: ${pdfBytes.length} bytes');

      // Save to file
      final filePath = await _savePDFFile(pdfBytes, prompt);
      print('📄 PDF: PDF saved to: $filePath');

      return filePath;
    } catch (e) {
      print('📄 PDF: Error generating PDF: $e');
      rethrow;
    }
  }

  static void _addTitlePage(pw.Document pdf, String prompt) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'AI Visualizer',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Infographic Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Topic: $prompt',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.normal,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Generated with AI Visualizer',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<String> _savePDFFile(Uint8List pdfBytes, String prompt) async {
    try {
      // Try to get external storage first, fallback to internal storage
      Directory directory;
      try {
        // Try external storage first
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (e) {
        print('📄 PDF: External storage not available, using internal: $e');
        // Fallback to internal storage
        directory = await getApplicationDocumentsDirectory();
      }
      
      final pdfDir = Directory('${directory.path}/PDF');
      
      // Create PDF directory if it doesn't exist
      if (!pdfDir.existsSync()) {
        pdfDir.createSync(recursive: true);
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedPrompt = prompt.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = 'infographic_${sanitizedPrompt}_$timestamp.pdf';
      final filePath = '${pdfDir.path}/$fileName';

      // Save PDF file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      print('📄 PDF: File saved to $filePath');
      return filePath;
    } catch (e) {
      print('📄 PDF: Error saving PDF file: $e');
      rethrow;
    }
  }
}
