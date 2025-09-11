import 'dart:convert';
import 'dart:developer' as dp;
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/infographic_model.dart';

class GeminiService {
  static const String _apiKey =
      // 'AIzaSyAUY0dVblf1jdSKWybm4vDrGtMK7apNjPc'; // Replace with your actual API key
      'AIzaSyCRRbXebrOmc7AUFFCUlFzc0PzJQA19Q8o'; // Replace with your actual API key
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'models/gemini-2.0-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 8192,
        // responseMimeType: 'text/plain',
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'html': Schema.array(items: Schema.string()),
            'css': Schema.array(items: Schema.string()),
          },
          requiredProperties: ['html', 'css'],
        ),
      ),
      systemInstruction: Content.text('''You are an infographic generator.
respond with ONLY a JSON object in this exact format:
{
  "html": "Complete HTML File code including head and body. head should contain all the resourses we are using in body like any icons or other stuff for the infographic content.complete file structure",
  "css": "complete CSS File code to attach with Html for for styling the infographic. full code nothing else."
}

Requirements:
1. Create a visually appealing infographic poster on a give topic with modern design
2. Use attractive colors, fonts, and layout
3. Include relevant icons, charts, or visual elements using CSS
4. Use very minimal text and more diagrams, images and icons.
5. Use semantic HTML elements
6. Use different stylings grids to make fancy dymanic look. 
7. Add relevant statistics, facts, or key points about the topic
8. Use Different colors according to the topic. create a proper theme.
9. Make text elements easily identifiable with classes for editing
10. Ensure the design is professional and informative
11. only make  asingle page in portrait view to represent everything on a single page (9:16 aspect ratio)
    - Width = 100vw
    - Max-height = calc(100vw * 16 / 9)
    - size of everything manually in vw or % to keep sizes calculated and fit inside single page.
    - All child elements must size themselves relative to parent (%, vw), not px or vh.
    - keep the text sizes very small around 0.1 vw to 0.5 vw.
    - Keep content minimal to fit within one 9:16 frame. Do not exceed.
    - if there is details tetxt keep it more small to fit in less space.


The HTML should be complete body content (no DOCTYPE, html, head tags needed).
The CSS should be comprehensive styling for the HTML content.
Make sure all text content is wrapped in elements with descriptive classes like "title", "subtitle", "fact", "statistic", etc.
'''),
    );
  }

  Future<InfographicModel?> generateInfographic(String prompt) async {
    try {
      final content = [
        Content.text(
          'Create an verticle poster design on topic: "$prompt"  keep the text sizes very small around 0.1 vw to 0.5 vw.Use at least one image url from freepik as well as set onerror to swap in a random https://picsum.photos/600/400, include icons from font awesome or material icons or heroicons or table icons or chart icons or diagram icons or graph icons or iconify icons or any other icons,make variety of charts and diagrams ',
        ),
      ];
      final response = await _model.generateContent(content);
      // dp.log(response.text!);
      // final response = '''
      // ```json
      //       {
      //         "html": "\"\"" ,"css": "\"\""   }
      //       ```
      // ''';
      // final response = '''
      // ```json
      //       {
      //         "html": "<div class=\"container\">\n  <header>\n    <h1 class=\"title\">Variables in C++</h1>\n    <p class=\"subtitle\">Understanding the Fundamentals</p>\n  </header>\n\n  <section class=\"overview\">\n    <h2 class=\"section-title\">What are Variables?</h2>\n    <p class=\"fact\">Variables are named storage locations that hold data values. They are the fundamental building blocks of any C++ program, enabling you to store, manipulate, and retrieve information.</p>\n    <img src=\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect x='10' y='10' width='80' height='80' fill='%234CAF50'/%3E%3Ctext x='50' y='50' dominant-baseline='middle' text-anchor='middle' fill='white' font-size='12'%3EVARIABLE%3C/text%3E%3C/svg%3E\" alt=\"Variable Icon\" class=\"icon\">\n  </section>\n\n  <section class=\"types\">\n    <h2 class=\"section-title\">Variable Types</h2>\n    <div class=\"type-grid\">\n      <div class=\"type-item\">\n        <h3 class=\"type-name\">Integer (int)</h3>\n        <p class=\"type-description\">Stores whole numbers (e.g., -10, 0, 25).</p>\n      </div>\n      <div class=\"type-item\">\n        <h3 class=\"type-name\">Floating-point (float/double)</h3>\n        <p class=\"type-description\">Stores decimal numbers (e.g., 3.14, -2.5).</p>\n      </div>\n      <div class=\"type-item\">\n        <h3 class=\"type-name\">Character (char)</h3>\n        <p class=\"type-description\">Stores a single character (e.g., 'A', 'z').</p>\n      </div>\n      <div class=\"type-item\">\n        <h3 class=\"type-name\">Boolean (bool)</h3>\n        <p class=\"type-description\">Stores a true or false value.</p>\n      </div>\n    </div>\n  </section>\n\n  <section class=\"declaration\">\n    <h2 class=\"section-title\">Declaration and Initialization</h2>\n    <p class=\"fact\">Before using a variable, you must declare it. Initialization assigns an initial value to the variable.</p>\n    <div class=\"code-example\">\n      <p class=\"code-line\"><code>int age; // Declaration</code></p>\n      <p class=\"code-line\"><code>age = 30; // Initialization</code></p>\n      <p class=\"code-line\"><code>int score = 100; // Declaration and Initialization</code></p>\n    </div>\n  </section>\n\n  <section class=\"scope\">\n    <h2 class=\"section-title\">Variable Scope</h2>\n    <p class=\"fact\">Scope determines where a variable can be accessed within your code. Local variables are accessible within the block they are defined, while global variables are accessible throughout the program.</p>\n    <div class=\"scope-illustration\">\n      <img src=\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='40' fill='%23f44336'/%3E%3Ctext x='50' y='50' dominant-baseline='middle' text-anchor='middle' fill='white' font-size='10'%3ELocal Scope%3C/text%3E%3C/svg%3E\" alt=\"Local Scope\" class=\"scope-icon\">\n      <img src=\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='40' fill='%232196F3'/%3E%3Ctext x='50' y='50' dominant-baseline='middle' text-anchor='middle' fill='white' font-size='10'%3EGlobal Scope%3C/text%3E%3C/svg%3E\" alt=\"Global Scope\" class=\"scope-icon\">\n    </div>\n  </section>\n\n  <section class=\"usage\">\n    <h2 class=\"section-title\">Usage in C++</h2>\n    <ul class=\"usage-list\">\n      <li class=\"usage-item\">Storing Data</li>\n      <li class=\"usage-item\">Performing Calculations</li>\n      <li class=\"usage-item\">Controlling Program Flow</li>\n    </ul>\n  </section>\n\n  <footer class=\"footer\">\n    <p class=\"footer-text\">© 2024 Infographic by AI</p>\n  </footer>\n</div>\n",
      //         "css": "body {\n  font-family: 'Arial', sans-serif;\n  margin: 0;\n  padding: 0;\n  background-color: #f4f4f4;\n  color: #333;\n  line-height: 1.6;\n  display: flex;\n  justify-content: center;\n  align-items: flex-start;\n  min-height: 100vh;\n}\n\n.container {\n  max-width: 400px;\n  padding: 20px;\n  background-color: #fff;\n  border-radius: 8px;\n  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);\n  margin-top: 20px;\n}\n\nheader {\n  text-align: center;\n  margin-bottom: 20px;\n}\n\n.title {\n  font-size: 2em;\n  color: #007bff;\n  margin-bottom: 5px;\n}\n\n.subtitle {\n  font-size: 1.1em;\n  color: #6c757d;\n}\n\n.section-title {\n  font-size: 1.5em;\n  color: #333;\n  margin-bottom: 15px;\n  border-bottom: 1px solid #ccc;\n  padding-bottom: 5px;\n}\n\n.overview, .types, .declaration, .scope, .usage {\n  margin-bottom: 20px;\n  padding: 10px;\n  border-radius: 4px;\n  background-color: #f9f9f9;\n}\n\n.fact {\n  margin-bottom: 10px;\n}\n\n.icon {\n  width: 50px;\n  height: 50px;\n  display: block;\n  margin: 15px auto;\n}\n\n.type-grid {\n  display: grid;\n  grid-template-columns: 1fr;\n  gap: 15px;\n}\n\n.type-item {\n  padding: 10px;\n  border: 1px solid #ddd;\n  border-radius: 4px;\n  background-color: #fff;\n}\n\n.type-name {\n  font-weight: bold;\n  margin-bottom: 5px;\n}\n\n.type-description {\n  font-size: 0.9em;\n}\n\n.code-example {\n  background-color: #f0f0f0;\n  padding: 10px;\n  border-radius: 4px;\n}\n\n.code-line {\n  font-family: monospace;\n  font-size: 0.9em;\n}\n\n.scope-illustration {\n    display: flex;\n    justify-content: space-around;\n    margin-top: 15px;\n}\n\n.scope-icon {\n  width: 40px;\n  height: 40px;\n}\n\n.usage-list {\n  list-style: none;\n  padding: 0;\n}\n\n.usage-item {\n  padding: 8px;\n  border-bottom: 1px solid #eee;\n}\n\n.usage-item:last-child {\n  border-bottom: none;\n}\n\n.footer {\n  text-align: center;\n  margin-top: 20px;\n  padding-top: 10px;\n  border-top: 1px solid #eee;\n  font-size: 0.8em;\n  color: #666;\n}\n\n@media (max-width: 480px) {\n  .container {\n    max-width: 90%;\n  }\n\n  .type-grid {\n    grid-template-columns: 1fr;\n  }\n}\n"
      //       }
      //       ```
      // ''';
      String cleanedResponse = response.text!;
      // cleanedResponse = cleanedResponse.replaceAll(r'\"', '\\"');
      // cleanedResponse = cleanedResponse.replaceAllMapped(
      //   RegExp(r'":\s*"([^"]*?)"([^,}])'),
      //   (match) {
      //     // Escape quotes inside value
      //     final value = match.group(1)!.replaceAll('container', r'\\"');
      //     return '": "$value"${match.group(2)}';
      //   },
      // );
      // dp.log(cleanedResponse);
      print(response.text);
      // if (true) {
      if (response.text != null) {
        // Clean the response to extract JSON
        // cleanedResponse = response.text!.trim();
        // // String cleanedResponse = response.text!.trim();

        // // Remove markdown code blocks if present
        // if (cleanedResponse.startsWith('```json')) {
        //   cleanedResponse = cleanedResponse.substring(7);
        // }
        // if (cleanedResponse.startsWith('```')) {
        //   cleanedResponse = cleanedResponse.substring(3);
        // }
        // if (cleanedResponse.endsWith('```')) {
        //   cleanedResponse = cleanedResponse.substring(
        //     0,
        //     cleanedResponse.length - 3,
        //   );
        // }
        // cleanedResponse = cleanedResponse.replaceAll(r'\"', r'\\"');
        // cleanedResponse = cleanedResponse.trim();
        // dp.log(cleanedResponse);

        try {
          final jsonData = jsonDecode(cleanedResponse);
          // final jsonData = json.decode(cleanedResponse);
          // return InfographicModel(
          //   htmlCode: (jsonData['html'] as List).first ?? '',
          //   cssCode: (jsonData['css'] as List).first ?? '',
          //   prompt: prompt,
          // );
          return InfographicModel(
            htmlCode: (jsonData['html'] is List)
                ? (jsonData['html'] as List).join("\n")
                : (jsonData['html'] ?? ''),
            cssCode: (jsonData['css'] is List)
                ? (jsonData['css'] as List).join("\n")
                : (jsonData['css'] ?? ''),
            prompt: prompt,
          );
        } catch (e) {
          dp.log('JSON parsing error: $e');
          // dp.log('Response: $cleanedResponse');
          return null;
        }
      }
      return null;
    } catch (e) {
      dp.log('Error generating infographic: $e');
      return null;
    }
  }
}
