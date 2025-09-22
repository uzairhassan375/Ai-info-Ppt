import 'dart:convert';
import 'dart:developer' as dp;
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
      systemInstruction: Content.text('''You are a professional infographic designer and data visualization expert.
respond with ONLY a JSON object in this exact format:
{
  "html": "Complete HTML File code including head and body. head should contain all the resources we are using in body like any icons or other stuff for the infographic content.complete file structure",
  "css": "complete CSS File code to attach with Html for styling the infographic. full code nothing else."
}

PROFESSIONAL INFOGRAPHIC REQUIREMENTS:

1. DATA RICHNESS & CONTENT (Generate 3x more data):
   - Include at least 15-20 key statistics, facts, or data points
   - Add multiple comparison charts, bar graphs, pie charts, or line graphs
   - Include at least 5-7 different sections with unique data
   - Add trending data, growth percentages, and comparative metrics
   - Include relevant quotes, expert insights, or case studies
   - Add timeline elements, process flows, or step-by-step guides
   - Include before/after comparisons or pros/cons analysis

2. VISUAL DESIGN & STYLING:
   - Use modern CSS gradients, shadows, and animations
   - Implement glassmorphism effects, card-based layouts
   - Add hover effects, smooth transitions, and micro-interactions
   - Use professional color schemes with 3-5 complementary colors
   - Include geometric shapes, patterns, and decorative elements
   - Add CSS-generated charts, progress bars, and data visualizations
   - Use modern typography with Google Fonts integration

3. MOBILE-FIRST LAYOUT & STRUCTURE:
   - Create a single-page portrait design optimized for mobile screens (9:16 aspect ratio)
   - Use single-column layout to maximize readability on narrow screens
   - Implement vertical stacking with proper spacing between sections
   - Avoid horizontal columns that cause content overflow on mobile
   - Use full-width cards and sections for better space utilization
   - Create visual hierarchy with proper spacing, not just text sizes
   - Include header, main content sections, and footer with consistent spacing

4. TECHNICAL SPECIFICATIONS FOR MOBILE:
   - Width = 100vw, Max-height = calc(100vw * 16 / 9)
   - All sizing in vw, %, or relative units (no px, vh)
   - Text sizes: 1.2vw to 4vw for better mobile readability
   - Use full-width containers (95-98vw) with minimal margins (1-2vw)
   - Stack elements vertically instead of horizontal columns
   - Include Font Awesome icons, Material Icons, or custom SVG icons
   - Add at least one high-quality image from Unsplash or Pexels
   - Implement CSS animations and transitions optimized for mobile

5. CONTENT ELEMENTS TO INCLUDE:
   - Eye-catching title with subtitle
   - 3-4 main data sections with statistics
   - 2-3 comparison charts or infographics
   - Key takeaways or bullet points
   - Visual icons and illustrations
   - Color-coded categories or themes
   - Call-to-action or conclusion section

6. MOBILE-FIRST PROFESSIONAL TOUCHES:
   - Use data visualization libraries concepts (Chart.js style CSS)
   - Add subtle animations and hover effects optimized for touch
   - Include professional color gradients and shadows
   - Use modern UI patterns like full-width cards, badges, and progress indicators
   - Add visual elements like arrows, connectors, and flow diagrams (vertical orientation)
   - Include social proof elements or credibility indicators
   - Ensure all interactive elements are touch-friendly (minimum 44px equivalent)
   - Use vertical flow diagrams and process charts instead of horizontal ones
   - Create mobile-optimized charts that stack vertically when needed

7. MOBILE LAYOUT PATTERNS TO USE:
   - Header section: Full-width title with subtitle (2-3vw padding)
   - Statistics section: Stack statistics vertically, not side-by-side
   - Chart section: Full-width charts that scale properly on mobile
   - Content sections: Single-column cards with 3-5vw spacing
   - Footer section: Full-width with proper mobile typography
   - Avoid: Multi-column grids, horizontal sidebars, cramped layouts
   - Use: Vertical flow, generous white space, touch-friendly sizing

The HTML should be complete body content (no DOCTYPE, html, head tags needed).
The CSS should be comprehensive styling with mobile-first design patterns.
Make sure all text content is wrapped in elements with descriptive classes like "title", "subtitle", "fact", "statistic", "chart", "data-point", etc.

Create an infographic that looks like it was designed by a professional design agency with rich data, beautiful visuals, and modern styling optimized specifically for mobile viewing that will impress users.
'''),
    );
  }

  Future<InfographicModel?> generateInfographic(String prompt) async {
    try {
      final content = [
        Content.text(
          '''Create a comprehensive, data-rich vertical infographic poster on topic: "$prompt"
          
          REQUIREMENTS FOR THIS SPECIFIC INFOGRAPHIC:
          
          1. CONTENT DENSITY: Generate at least 3x more data than typical infographics:
             - Include 15-25 key statistics, facts, or data points
             - Add 4-6 different data visualization sections
             - Include multiple charts: bar charts, pie charts, line graphs, progress bars
             - Add comparison data, trends, and growth metrics
             - Include expert quotes, case studies, or real-world examples
             - Add timeline elements, process flows, or step-by-step breakdowns
          
          2. VISUAL RICHNESS: Make it visually stunning and professional:
             - Use at least 3-5 high-quality images from Unsplash, Pexels, or Pixabay
             - Include 20+ icons from Font Awesome, Material Icons, or Heroicons
             - Add CSS-generated charts, progress bars, and data visualizations
             - Use modern gradients, glassmorphism effects, and shadows
             - Include geometric shapes, patterns, and decorative elements
             - Add subtle animations and hover effects
          
          3. MOBILE-OPTIMIZED TECHNICAL IMPLEMENTATION:
             - Text sizes: 1.5vw to 4vw for better mobile readability
             - Use single-column vertical layout (NO horizontal columns)
             - Full-width sections (95-98vw) with minimal side margins (1-2vw)
             - Stack all content vertically to prevent overflow
             - Include professional color schemes with proper contrast
             - Add card-based sections with generous spacing (3-5vw between sections)
             - Implement modern typography with Google Fonts
             - Use CSS animations and smooth transitions optimized for mobile
             - Ensure all charts and data visualizations fit within mobile width
          
          4. DATA VISUALIZATION: Create multiple interactive-style charts:
             - Bar charts showing comparisons
             - Pie charts for percentage breakdowns
             - Progress bars for completion rates
             - Line graphs for trends over time
             - Donut charts for category distributions
             - Infographic-style icons and illustrations
          
          MOBILE DESIGN REQUIREMENTS:
          - NEVER use horizontal columns or side-by-side layouts
          - ALWAYS stack content vertically for mobile optimization
          - Use full-width sections (95-98vw) with minimal margins
          - Ensure all text is readable on mobile screens (minimum 1.5vw)
          - Create generous spacing between sections (3-5vw)
          - Make charts and visualizations fit mobile width perfectly
          - Use single-column layout throughout the entire design
          - Prioritize vertical scrolling over horizontal overflow
          
          Make this infographic so rich with data and visually appealing that users will be impressed by the depth and professional quality. Include everything from statistics to visual elements that tell a complete story about the topic.
          
          Remember: This should look like it was created by a professional design agency with extensive research and beautiful data visualization, optimized specifically for mobile viewing.''',
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
