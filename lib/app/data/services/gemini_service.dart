import 'dart:convert';
import 'dart:developer' as dp;
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/infographic_model.dart';
import 'unsplash_service.dart';

class GeminiService {
  static const String _apiKey =
      // 'AIzaSyAUY0dVblf1jdSKWybm4vDrGtMK7apNjPc'; // Replace with your actual API key
      'AIzaSyDYVQ7M8d5FckYRSGnC7yQaJN_RdVqNZQM'; // Replace with your actual API key
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

CRITICAL REQUIREMENTS - MANDATORY COMPLIANCE:
1. IMAGE RELEVANCE IS ABSOLUTELY CRITICAL - NO EXCEPTIONS
2. PROFESSIONAL DATA PRESENTATION IS REQUIRED
3. CONSISTENCY AND ACCURACY ARE MANDATORY
4. USABILITY MUST BE OPTIMIZED

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
   - MANDATORY: Use ONLY highly relevant images that DIRECTLY match the topic
   - For country flags: Use flagcdn.com or countryflagsapi.com
   - For general images: Use Unsplash, Pexels, or Pixabay with topic-specific photo IDs
   - CRITICAL: Analyze the prompt topic and select images that directly relate to it
   - Examples: AI topic → AI/technology images, Pakistan topic → Pakistan flag, Health topic → medical images
   - If exact images aren't available, use GENERIC images from the same category
   - Food subcategories (Kolkata biryani, Lucknowi biryani) → use generic biryani/food images
   - City subcategories → use generic city/landmark images if specific city images aren't available
   - Include proper image fallbacks with onerror attributes
   - NEVER use random images that don't relate to the prompt topic
   - NEVER use the same image in multiple sections - each section must have UNIQUE images
   - Each section should have images that relate to that specific section's content
   - IMAGE RELEVANCE CHECK: Ask yourself "Would a user immediately understand why this image is here?"

3. MOBILE-FIRST LAYOUT & STRUCTURE:
   - Create a single-page portrait design optimized for mobile screens (9:16 aspect ratio)
   - Use single-column layout to maximize readability on narrow screens
   - Implement vertical stacking with proper spacing between sections
   - Avoid horizontal columns that cause content overflow on mobile
   - Use full-width cards and sections for better space utilization
   - Create visual hierarchy with proper spacing, not just text sizes
   - Include header, main content sections, and footer with consistent spacing
   - CRITICAL: Ensure NO data overlap - each element must have dedicated space
   - Use generous padding (2-3vw) around all content elements
   - Add clear visual separation between different data sections
   - Ensure all text is readable with proper contrast and spacing

4. TECHNICAL SPECIFICATIONS FOR MOBILE:
   - Width = 100vw, Max-height = calc(100vw * 16 / 9)
   - All sizing in vw, %, or relative units (no px, vh)
   - Text sizes: 1.2vw to 4vw for better mobile readability
   - Use full-width containers (95-98vw) with minimal margins (1-2vw)
   - Stack elements vertically instead of horizontal columns
   - Include Font Awesome icons, Material Icons, or custom SVG icons
   - Add at least one high-quality image from reliable sources
   - Use working image URLs: flagcdn.com for flags, Unsplash/Pexels for general images
   - Implement CSS animations and transitions optimized for mobile
   - Include image fallbacks: onerror="this.src='https://picsum.photos/600/400'"

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
   
   PROFESSIONAL STATISTICS LAYOUT - MANDATORY:
   - Each statistic in its own card with 2-3vw padding
   - Clear visual separation between different data points
   - Use background colors or borders to distinguish sections
   - Ensure text never overlaps with images or other elements
   - Use consistent spacing (3-5vw) between all content blocks
   - Add visual hierarchy with different text sizes and weights
   - Use professional color schemes with high contrast
   - Implement consistent typography throughout
   - Add subtle shadows and modern styling
   - Ensure all data is easily readable and scannable
   - Use icons to support each statistic or data point
   - Create clear visual hierarchy with proper spacing

The HTML should be complete body content (no DOCTYPE, html, head tags needed).
The CSS should be comprehensive styling with mobile-first design patterns.
Make sure all text content is wrapped in elements with descriptive classes like "title", "subtitle", "fact", "statistic", "chart", "data-point", etc.

IMAGE SOURCE WEBSITES AND SEARCH INSTRUCTIONS:

WEBSITE NAMES TO USE FOR IMAGES:
- Unsplash.com - Search for high-quality stock photos
- Pexels.com - Free stock photos and videos
- Pixabay.com - Free images and videos
- Flagcdn.com - Country flags (use format: flagcdn.com/w320/[country-code].png)
- Picsum.photos - Random placeholder images for fallbacks

SEARCH INSTRUCTIONS FOR DIFFERENT TOPICS:
- Country flags: Use flagcdn.com with country codes (pk for Pakistan, in for India, us for USA)
- Cricket/Sports: Search Unsplash/Pexels for "cricket", "cricket stadium", "cricket players", "sports"
- Food topics: Search for "food", "cooking", "restaurant", "ingredients", "biryani", "Indian food"
- Technology/AI: Search for "artificial intelligence", "technology", "robots", "computers", "digital"
- Business: Search for "business", "office", "corporate", "meetings", "finance"
- Health: Search for "healthcare", "medical", "doctor", "hospital", "wellness"
- Education: Search for "education", "school", "learning", "students", "classroom"
- Travel: Search for "travel", "destinations", "landmarks", "tourism"

IMPORTANT: Always use working image URLs from these websites and add onerror fallbacks

SECTION-SPECIFIC IMAGE SEARCH INSTRUCTIONS:

FOR CRICKET/SPORTS TOPICS (e.g., 1992 Cricket World Cup, sports stats):
- Header: Search Unsplash/Pexels for "cricket world cup" or "cricket tournament" - find cricket world cup main image
- Statistics: Search for "cricket statistics" or "sports data" - find cricket data/statistics images
- Charts: Search for "cricket analytics" or "sports charts" - find cricket data visualization images
- Content 1: Search for "cricket world cup stadium" or "Melbourne cricket ground" - find world cup stadium images
- Content 2: Search for "cricket world cup players" or "1992 cricket" - find world cup player images
- Content 3: Search for "cricket world cup trophy" or "cricket championship" - find trophy/championship images
- Footer: Search for "cricket world cup celebration" or "cricket victory" - find celebration images
- NEVER use mountain, landscape, or unrelated images for sports topics!
- ALWAYS use DIFFERENT images for each section - never repeat the same image!

FOR FOOD TOPICS (e.g., biryani, Indian cuisine):
- Header: Search for the main dish (e.g., "biryani", "Indian food") - find main dish image
- Statistics: Search for "cooking" or "kitchen" - find cooking/kitchen images
- Charts: Search for specific cuisine (e.g., "Indian food", "curry") - find cuisine images
- Content 1: Search for "ingredients" or "spices" - find ingredient images
- Content 2: Search for "restaurant" or "dining" - find dining/restaurant images
- Content 3: Search for "traditional cooking" or "food preparation" - find cooking images
- Footer: Search for "food preparation" or "kitchen" - find food prep images

FOR TECHNOLOGY TOPICS (e.g., AI, blockchain):
- Header: Search for "artificial intelligence" or "technology" - find AI/tech images
- Statistics: Search for "data analytics" or "charts" - find data visualization images
- Charts: Search for "data charts" or "analytics" - find chart/graph images
- Content 1: Search for "AI robots" or "artificial intelligence" - find AI/robotics images
- Content 2: Search for "digital technology" or "cybersecurity" - find digital/cyber images
- Content 3: Search for "innovation" or "technology" - find innovation images
- Footer: Search for "future technology" or "AI" - find future tech images

FOR COUNTRY TOPICS (e.g., Pakistan, India):
- Header: Use flagcdn.com with country code (e.g., flagcdn.com/w320/pk.png for Pakistan)
- Statistics: Search for "landmarks" or city name - find landmark images
- Charts: Search for "data analytics" or "charts" - find data/chart images
- Content 1: Search for "culture" or country name - find cultural images
- Content 2: Search for "business" or "economy" - find business/economic images
- Content 3: Search for "tourism" or country name - find tourism images
- Footer: Search for "heritage" or country name - find heritage images

IMAGE RELEVANCE CHECKLIST - MANDATORY:
- Does the image directly relate to the prompt topic? YES/NO
- Is it from the same category as the topic? YES/NO
- Would a user understand the connection immediately? YES/NO
- Is it professional and high-quality? YES/NO
- Is this image UNIQUE and not used in other sections? YES/NO
- If NO to any question, find a different image!

IMPORTANT: Choose images that directly relate to the user's prompt topic! If exact images aren't available, use generic images from the same category.

Create an infographic that looks like it was designed by a professional design agency with rich data, beautiful visuals, and modern styling optimized specifically for mobile viewing that will impress users.
'''),
    );
  }

  Future<InfographicModel?> generateInfographic(String prompt) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 2);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Debug logging for image selection tracking
        print('🔍 DEBUG: Starting infographic generation for prompt: "$prompt" (Attempt $attempt/$maxRetries)');
        print('🔍 DEBUG: Prompt contains cricket keywords: ${_containsCricketKeywords(prompt)}');
        print('🔍 DEBUG: Prompt contains food keywords: ${_containsFoodKeywords(prompt)}');
        print('🔍 DEBUG: Prompt contains country keywords: ${_containsCountryKeywords(prompt)}');
        print('🔍 DEBUG: Prompt contains tech keywords: ${_containsTechKeywords(prompt)}');
        
        // Get Unsplash images for the prompt
        print('🔍 DEBUG: Getting Unsplash images for prompt...');
        final unsplashImages = await UnsplashService.getInfographicImages(prompt);
        print('🔍 DEBUG: Found ${unsplashImages.length} Unsplash images');
        for (final entry in unsplashImages.entries) {
          print('🔍 DEBUG: ${entry.key}: ${entry.value}');
        }
      
      final content = [
        Content.text(
          '''Create a comprehensive, data-rich vertical infographic poster on topic: "$prompt"
          
          🔍 DEBUG INFO FOR IMAGE SELECTION:
          - PROMPT ANALYSIS: "$prompt"
          - CRICKET TOPIC DETECTED: ${_containsCricketKeywords(prompt)}
          - FOOD TOPIC DETECTED: ${_containsFoodKeywords(prompt)}
          - COUNTRY TOPIC DETECTED: ${_containsCountryKeywords(prompt)}
          - TECH TOPIC DETECTED: ${_containsTechKeywords(prompt)}
          - EXPECTED IMAGE TYPE: ${_getExpectedImageType(prompt)}
          
          🖼️ UNSPLASH IMAGES PROVIDED:
          ${unsplashImages.isNotEmpty ? unsplashImages.entries.map((e) => '- ${e.key}: ${e.value}').join('\n') : 'No Unsplash images found'}
          
          🚨🚨🚨 MINIMAL IMAGE STRATEGY - FOCUS ON DATA 🚨🚨🚨
          CRITICAL INSTRUCTIONS:
          - MANDATORY: Use ONLY 2-3 images total (header + 1-2 strategic placements)
          - MANDATORY: Focus on DATA DENSITY over image quantity
          - MANDATORY: Use the provided Unsplash images above (max 3 images)
          - MANDATORY: If no Unsplash images provided, use fallback sources (max 3 images)
          - MANDATORY: Prioritize text, statistics, charts, and data visualizations
          - MANDATORY: Generate 5x more data content than typical infographics
          
          CRITICAL DEBUG REQUIREMENTS:
          - Each section MUST have a DIFFERENT image URL
          - Log the image selection reasoning for each section
          - Ensure images match the detected topic type
          - Never use the same image URL twice
          
          REQUIREMENTS FOR THIS SPECIFIC INFOGRAPHIC:
          
          🚨 CRITICAL IMAGE REQUIREMENTS - MANDATORY COMPLIANCE 🚨
          - MANDATORY: Analyze the prompt topic VERY carefully and select images that DIRECTLY relate to it
          - MANDATORY: For cricket topics, use ONLY cricket-related images (stadiums, players, equipment, trophies)
          - MANDATORY: NEVER use the same image in multiple sections - each section must have UNIQUE, relevant images
          - MANDATORY: Test image URLs before using them - they must be working and accessible
          - MANDATORY: Use simple, working image URLs from reliable sources
          - For country topics (Pakistan, India, USA): Use actual flag images from flagcdn.com
          - For technology topics (AI, blockchain, etc.): Use technology-related images from Unsplash
          - For business topics: Use business, office, or corporate images
          - For health topics: Use medical, healthcare, or wellness images
          - For education topics: Use school, learning, or academic images
          - For sports topics: Use sports equipment, stadiums, or athletes
          - For cricket topics (World Cup, cricket stats): Use cricket stadiums, players, equipment, or cricket-related images
          - For food topics: Use food, restaurant, or cooking images
          - For travel topics: Use destination, landmark, or travel images
          - NEVER use mountain, landscape, or unrelated images for sports/cricket topics
          - NEVER use random or irrelevant images - they must match the prompt topic EXACTLY
          - If you can't find exact images for specific subcategories, use GENERIC images from the same category
          - Examples: For "Kolkata biryani" or "Lucknowi biryani" → use generic biryani/food images, NOT keyboard images
          - For specific cities → use generic city/landmark images if exact city images aren't available
          - For specific dishes → use generic food/cooking images if exact dish images aren't available
          
          CRICKET WORLD CUP SPECIFIC REQUIREMENTS (CRITICAL):
          - For "1992 Cricket World Cup" or similar cricket world cup topics:
            * Header: MUST search for "cricket world cup" or "cricket tournament" images
            * Statistics: MUST search for "cricket statistics" or "sports data" images  
            * Charts: MUST search for "cricket analytics" or "sports charts" images
            * Content 1: MUST search for "cricket stadium" or "cricket ground" images
            * Content 2: MUST search for "cricket players" or "cricket team" images
            * Content 3: MUST search for "cricket trophy" or "cricket championship" images
            * Footer: MUST search for "cricket celebration" or "cricket victory" images
          - NEVER use the same image twice - each section needs a DIFFERENT image
          - NEVER use mountain, landscape, or unrelated images for cricket topics
          - ALWAYS search for cricket-specific keywords, not generic sports
          - Each image must be UNIQUE and relevant to cricket world cup context
          - Always add onerror fallbacks: onerror="this.src='https://picsum.photos/600/400'"
          - Use website names (Unsplash.com, Pexels.com, Pixabay.com) with specific search terms
          - Search for relevant images using appropriate keywords that match the topic
          - DOUBLE-CHECK: Ensure every image is contextually relevant to the prompt topic
          - IMAGE RELEVANCE TEST: Ask "Would a user immediately understand why this image is here?"
          - If the answer is NO, find a different image that better relates to the topic
          
          CRITICAL ANTI-REPETITION RULES:
          - MANDATORY: Each section MUST have a DIFFERENT image - NO EXCEPTIONS
          - MANDATORY: Never use the same image URL in multiple sections
          - MANDATORY: Each image must be UNIQUE and relevant to its specific section
          - MANDATORY: For cricket topics, use different cricket-related images for each section
          - MANDATORY: Check that all images are different before finalizing the infographic
          - MANDATORY: If you find yourself using the same image, search for a different one
          
          SECTION-SPECIFIC IMAGE REQUIREMENTS:
          - Header section: Use main topic image (flag for countries, main subject image for others)
          - Statistics section: Use data/analytics related images
          - Chart section: Use chart/graph related images or topic-specific visuals
          - Content section 1: Use specific aspect of the topic (e.g., for food topics: cooking, ingredients, etc.)
          - Content section 2: Use different aspect of the topic (e.g., for food topics: restaurant, dining, etc.)
          - Content section 3: Use another aspect of the topic (e.g., for food topics: traditional, modern, etc.)
          - Footer section: Use concluding/summary related images
          - NEVER repeat the same image in different sections
          
          CRICKET/SPORTS TOPIC SECTION REQUIREMENTS:
          - Header: Cricket/sports main image (NOT mountains or landscapes)
          - Statistics: Data/analytics charts or sports statistics images
          - Charts: Sports analytics or cricket-related visualizations
          - Content 1: Cricket stadium or field images
          - Content 2: Cricket players or team images
          - Content 3: Cricket equipment or match images
          - Footer: Cricket celebration or trophy images
          - NEVER use mountain, landscape, or unrelated images for any cricket section
          
          🏏 DYNAMIC CRICKET IMAGE SOURCES (USE MULTIPLE SOURCES):
          
          SOURCE 1 - UNSPLASH (High Quality):
          - Search: "cricket world cup", "cricket stadium", "cricket players", "cricket equipment"
          - Format: https://images.unsplash.com/photo-[ID]?w=600&h=400&fit=crop
          - Use different photo IDs for each section
          
          SOURCE 2 - PEXELS (Reliable):
          - Search: "cricket", "cricket stadium", "cricket players", "sports equipment"
          - Format: https://images.pexels.com/photos/[ID]/pexels-[photographer]-[ID].jpeg
          - Use different photo IDs for each section
          
          SOURCE 3 - PIXABAY (Diverse):
          - Search: "cricket", "cricket world cup", "cricket stadium", "cricket players"
          - Format: https://pixabay.com/get/[ID]-[hash].jpg
          - Use different photo IDs for each section
          
          SOURCE 4 - WIKIMEDIA (Official):
          - Search: "cricket world cup", "cricket stadium", "cricket equipment"
          - Format: https://upload.wikimedia.org/wikipedia/commons/[path]
          - Use different images for each section
          
          SOURCE 5 - GOOGLE IMAGES (Fallback):
          - Search: "cricket world cup", "cricket stadium", "cricket players"
          - Use reliable, working URLs from Google Images
          - Test URLs before using them
          
          🎯 DYNAMIC SOURCE SELECTION FOR DIFFERENT TOPICS:
          
          FOR FOOD TOPICS (biryani, Indian cuisine, etc.):
          - Unsplash: "food", "cooking", "restaurant", "cuisine"
          - Pexels: "food", "cooking", "kitchen", "dining"
          - Pixabay: "food", "cooking", "restaurant", "cuisine"
          - Wikimedia: "food", "cuisine", "cooking"
          
          FOR TECHNOLOGY TOPICS (AI, blockchain, etc.):
          - Unsplash: "technology", "artificial intelligence", "digital"
          - Pexels: "technology", "AI", "computer", "digital"
          - Pixabay: "technology", "artificial intelligence", "digital"
          - Wikimedia: "technology", "artificial intelligence"
          
          FOR COUNTRY TOPICS (Pakistan, India, etc.):
          - Flagcdn: Country flags (flagcdn.com/w320/[country-code].png)
          - Unsplash: "country name", "landmarks", "culture"
          - Pexels: "country name", "landmarks", "heritage"
          - Wikimedia: "country name", "landmarks", "official images"
          
          🚨 DYNAMIC SELECTION STRATEGY:
          - For Header: Search for "cricket world cup" across multiple sources
          - For Statistics: Search for "cricket statistics" or "sports data"
          - For Charts: Search for "cricket stadium" or "sports venue"
          - For Content 1: Search for "cricket players" or "cricket team"
          - For Content 2: Search for "cricket equipment" or "cricket gear"
          - For Content 3: Search for "cricket celebration" or "cricket trophy"
          - For Footer: Search for "cricket victory" or "cricket championship"
          - Each section MUST use a DIFFERENT source and image
          - Test URLs and use fallbacks if they don't work
          
          1. ULTRA-HIGH CONTENT DENSITY: Generate 5x more data than typical infographics:
             - Include 30-50 key statistics, facts, or data points
             - Add 8-12 different data visualization sections
             - Include multiple chart types: bar charts, pie charts, line graphs, progress bars, donut charts, area charts, scatter plots, radar charts
             - Add detailed text explanations for each statistic (2-3 sentences each)
             - Include comparative data and trend analysis (year-over-year, regional comparisons)
             - Add historical context and future projections (5-year trends, predictions)
             - Include expert quotes, case studies, or real-world examples
             - Add timeline elements, process flows, or step-by-step breakdowns
             - Include demographic breakdowns, market analysis, and industry insights
             - Add cost analysis, ROI data, and financial metrics where relevant
             - Include geographic data, regional statistics, and location-based insights
             - Add performance metrics, rankings, and competitive analysis
             - Include user behavior data, engagement statistics, and usage patterns
          
          2. DATA VISUALIZATION RICHNESS: Make it data-rich and visually stunning:
             - Use ONLY 2-3 high-quality images (header + 1-2 strategic placements)
             - Focus on DATA VISUALIZATION: charts, graphs, progress bars, statistics
             - Include 30+ icons from Font Awesome, Material Icons, or Heroicons for data points
             - Add CSS-generated charts: bar charts, pie charts, line graphs, donut charts, area charts
             - Create progress bars, percentage circles, and trend indicators
             - Use modern gradients, glassmorphism effects, and shadows for charts
             - Include geometric shapes and patterns for data visualization
             - Add subtle animations for charts and data elements
             - NEVER use placeholder images or broken URLs
          
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
             
             CRITICAL LAYOUT REQUIREMENTS - NO DATA OVERLAP:
             - Each statistic must have its own dedicated space with clear separation
             - Use generous padding (2-3vw) around each data element
             - Ensure text never overlaps with images or other elements
             - Use clear visual hierarchy with different text sizes and weights
             - Add sufficient margins between all content blocks
             - Use background colors or borders to separate different sections
             - Ensure all text is readable and not cramped together
          
          4. DATA VISUALIZATION: Create multiple interactive-style charts:
             - Bar charts showing comparisons
             - Pie charts for percentage breakdowns
             - Progress bars for completion rates
             - Line graphs for trends over time
             - Donut charts for category distributions
             - Infographic-style icons and illustrations
          
          IMAGE REQUIREMENTS & FALLBACK STRATEGY:
          - Use MULTIPLE image sources for better reliability:
            * Unsplash.com - High-quality stock photos (test URLs first)
            * Pexels.com - Reliable free stock photos and videos
            * Pixabay.com - Diverse free images and videos
            * Wikimedia.org - Official, reliable images
            * Google Images - Fallback for specific searches
            * Flagcdn.com - Country flags (format: flagcdn.com/w320/[country-code].png)
          
          - For country flags: Use flagcdn.com with country codes (pk for Pakistan, in for India, us for USA)
          - For general images: Search across multiple sources with relevant keywords
          - For icons: Use Font Awesome CDN: https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css
          
          - FALLBACK STRATEGY (MANDATORY):
            * Primary: Try Unsplash/Pexels with specific keywords
            * Secondary: Try Pixabay/Wikimedia if primary fails
            * Tertiary: Use Google Images as last resort
            * Final: Use onerror="this.src='https://picsum.photos/600/400'" for broken images
          
          - NEVER use placeholder.com, via.placeholder.com, or broken URLs
          - Test image URLs before using them
          - Ensure images are relevant to the topic
          
          MOBILE DESIGN REQUIREMENTS:
          - NEVER use horizontal columns or side-by-side layouts
          - ALWAYS stack content vertically for mobile optimization
          - Use full-width sections (95-98vw) with minimal margins
          - Ensure all text is readable on mobile screens (minimum 1.5vw)
          - Create generous spacing between sections (3-5vw)
          - Make charts and visualizations fit mobile width perfectly
          - Use single-column layout throughout the entire design
          - Prioritize vertical scrolling over horizontal overflow
          
          CRITICAL LAYOUT REQUIREMENTS - NO OVERLAP:
          - Each statistic must have dedicated space with 2-3vw padding
          - Use clear visual separation between all content elements
          - Ensure text never overlaps with images or other elements
          - Add background colors or borders to separate sections
          - Use consistent spacing (3-5vw) between all content blocks
          - Create clear visual hierarchy with different text sizes
          - Ensure all content is easily readable and not cramped
          
          PROFESSIONAL DATA PRESENTATION REQUIREMENTS:
          - Use professional color schemes with high contrast
          - Implement consistent typography throughout
          - Add subtle shadows and modern styling
          - Ensure all data is easily readable and scannable
          - Use icons to support each statistic or data point
          - Create clear visual hierarchy with proper spacing
          - Use card-based layouts with proper padding
          - Add visual elements that enhance data understanding
          - Ensure consistency in styling across all sections
          
          IMAGE SELECTION STRATEGY:
          - Read the prompt topic carefully and understand what it's about
          - If it mentions a country (Pakistan, India, USA, etc.) → use that country's flag
          - If it's about AI, technology, or computers → use tech/AI images
          - If it's about health, medicine, or wellness → use healthcare images
          - If it's about business, finance, or economy → use business/corporate images
          - If it's about education, learning, or schools → use educational images
          - If it's about sports, fitness, or athletes → use sports images
          - If it's about cricket, World Cup, or cricket stats → use cricket/sports images (NOT mountains!)
          - If it's about food, cooking, or restaurants → use food images
          - If it's about travel, tourism, or destinations → use travel images
          
          FALLBACK STRATEGY FOR SPECIFIC SUBCATEGORIES:
          - For specific food dishes (Kolkata biryani, Lucknowi biryani, etc.) → use generic biryani/food images
          - For specific cities (Kolkata, Lucknow, etc.) → use generic city/landmark images
          - For specific cuisines (Indian, Chinese, etc.) → use generic cuisine images
          - For specific sports (cricket, football, etc.) → use generic sports images
          - For cricket topics (1992 World Cup, cricket stats, etc.) → use cricket stadiums, players, equipment images
          - NEVER use completely unrelated images (like keyboards for food topics, mountains for cricket topics)
          - Always ensure images are contextually relevant to the prompt topic
          
          IMAGE DIVERSITY REQUIREMENTS:
          - NEVER use the same image URL in multiple sections
          - Each section must have a UNIQUE, relevant image
          - Header section: Main topic image (flag for countries, main subject for others)
          - Statistics section: Data/analytics related images
          - Chart section: Chart/graph related images or topic-specific visuals
          - Content sections: Different aspects of the topic (cooking, ingredients, restaurant, etc.)
          - Footer section: Concluding/summary related images
          - Ensure visual variety while maintaining topic relevance
          
          Make this infographic so rich with data and visually appealing that users will be impressed by the depth and professional quality. Include everything from statistics to visual elements that tell a complete story about the topic.
          
          FINAL REMINDERS - CRITICAL SUCCESS FACTORS:
          - IMAGE RELEVANCE: Every image must directly relate to the topic - NO EXCEPTIONS
          - PROFESSIONAL PRESENTATION: Use modern styling, proper spacing, and high contrast
          - CONSISTENCY: Maintain consistent styling and spacing throughout
          - USABILITY: Ensure all content is easily readable and well-organized
          - ACCURACY: Present data clearly and professionally
          
          🚨🚨🚨 FINAL DATA-FOCUSED REMINDER 🚨🚨🚨
          CRITICAL CONTENT PRIORITY:
          - PRIMARY: Generate 30-50 statistics and data points
          - PRIMARY: Create 8-12 different chart types and visualizations
          - PRIMARY: Include detailed text explanations (2-3 sentences per statistic)
          - IMAGES: Use ONLY 2-3 images total (header + 1-2 strategic placements)
          - FALLBACK: If Unsplash images not available, use other sources (max 3 images)
          - Each section MUST have DIFFERENT data content
          - Focus on DATA DENSITY over image quantity
          - Use onerror fallbacks for any broken images
          - ALL content must be relevant to the topic and data-rich
          
          Remember: This should look like it was created by a professional design agency with extensive research and beautiful data visualization, optimized specifically for mobile viewing with highly relevant images.''',
        ),
      ];
        final response = await _model.generateContent(content);
        
        // Debug logging for API response
        print('🔍 DEBUG: Gemini API response received on attempt $attempt');
        print('🔍 DEBUG: Response length: ${response.text?.length ?? 0} characters');
        if (response.text != null && response.text!.isNotEmpty) {
          print('🔍 DEBUG: Response preview: ${response.text!.substring(0, response.text!.length > 200 ? 200 : response.text!.length)}...');
        }
      
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
          // Debug logging for JSON parsing
          print('🔍 DEBUG: Attempting to parse JSON response');
          print('🔍 DEBUG: Cleaned response length: ${cleanedResponse.length}');
          print('🔍 DEBUG: Cleaned response preview: ${cleanedResponse.substring(0, cleanedResponse.length > 300 ? 300 : cleanedResponse.length)}...');
          
          final jsonData = jsonDecode(cleanedResponse);
          
          // Debug logging for parsed JSON
          print('🔍 DEBUG: JSON parsed successfully');
          print('🔍 DEBUG: JSON keys: ${jsonData.keys.toList()}');
          if (jsonData.containsKey('html')) {
            print('🔍 DEBUG: HTML length: ${jsonData['html'].toString().length}');
            print('🔍 DEBUG: HTML preview: ${jsonData['html'].toString().substring(0, jsonData['html'].toString().length > 200 ? 200 : jsonData['html'].toString().length)}...');
          }
          if (jsonData.containsKey('css')) {
            print('🔍 DEBUG: CSS length: ${jsonData['css'].toString().length}');
          }
          
          // Debug logging for image analysis
          if (jsonData.containsKey('html')) {
            final htmlContent = jsonData['html'].toString();
            print('🔍 DEBUG: Analyzing images in HTML content...');
            
            // Count image tags
            final imageTags = RegExp(r'<img[^>]*>').allMatches(htmlContent).toList();
            print('🔍 DEBUG: Found ${imageTags.length} image tags in HTML');
            
            // Extract image sources
            final imageSources = <String>[];
            final srcRegex = RegExp(r'src="([^"]*)"');
            for (final match in imageTags) {
              final imgTag = match.group(0)!;
              final srcMatch = srcRegex.firstMatch(imgTag);
              if (srcMatch != null) {
                imageSources.add(srcMatch.group(1)!);
              }
            }
            
            print('🔍 DEBUG: Image sources found:');
            for (int i = 0; i < imageSources.length; i++) {
              print('🔍 DEBUG: Image ${i + 1}: ${imageSources[i]}');
            }
            
            // Check for duplicate images
            final uniqueImages = imageSources.toSet();
            if (uniqueImages.length != imageSources.length) {
              print('🔍 DEBUG: WARNING - Duplicate images detected!');
              print('🔍 DEBUG: Total images: ${imageSources.length}, Unique images: ${uniqueImages.length}');
              final duplicates = imageSources.where((img) => imageSources.indexOf(img) != imageSources.lastIndexOf(img)).toSet();
              print('🔍 DEBUG: Duplicate image URLs: $duplicates');
            } else {
              print('🔍 DEBUG: All images are unique - no duplicates found');
            }
            
            // Check for cricket relevance
            final cricketKeywords = ['cricket', 'stadium', 'players', 'bat', 'ball', 'wicket', 'world cup'];
            final cricketRelevantImages = imageSources.where((img) => 
              cricketKeywords.any((keyword) => img.toLowerCase().contains(keyword))
            ).toList();
            print('🔍 DEBUG: Cricket-relevant images: ${cricketRelevantImages.length}/${imageSources.length}');
            if (cricketRelevantImages.isNotEmpty) {
              print('🔍 DEBUG: Cricket-relevant image URLs: $cricketRelevantImages');
            }
            
            // Check image sources diversity
            final unsplashImages = imageSources.where((img) => img.contains('unsplash.com')).toList();
            final pexelsImages = imageSources.where((img) => img.contains('pexels.com')).toList();
            final pixabayImages = imageSources.where((img) => img.contains('pixabay.com')).toList();
            final wikimediaImages = imageSources.where((img) => img.contains('wikimedia.org')).toList();
            final googleImages = imageSources.where((img) => img.contains('google.com') || img.contains('googleusercontent.com')).toList();
            
            print('🔍 DEBUG: Image source diversity:');
            print('🔍 DEBUG: Unsplash: ${unsplashImages.length}');
            print('🔍 DEBUG: Pexels: ${pexelsImages.length}');
            print('🔍 DEBUG: Pixabay: ${pixabayImages.length}');
            print('🔍 DEBUG: Wikimedia: ${wikimediaImages.length}');
            print('🔍 DEBUG: Google: ${googleImages.length}');
            
            // Check if AI used the provided Unsplash images
            final providedUnsplashImages = unsplashImages.where((img) => 
              img.contains('images.unsplash.com/photo-')
            ).toList();
            print('🔍 DEBUG: Used provided Unsplash images: ${providedUnsplashImages.length}/${unsplashImages.length}');
            
            final totalSources = [unsplashImages, pexelsImages, pixabayImages, wikimediaImages, googleImages]
                .where((source) => source.isNotEmpty).length;
            print('🔍 DEBUG: Total image sources used: $totalSources/5');
            
            // Check data density (text content, statistics, charts)
            final textContent = htmlContent.toLowerCase();
            final statisticsCount = RegExp(r'\d+%|\d+\.\d+%|\d+\/\d+|\d+:\d+').allMatches(textContent).length;
            final chartElements = RegExp(r'chart|graph|progress|bar|pie|line').allMatches(textContent).length;
            final dataPoints = RegExp(r'statistic|data|metric|percentage|rate|growth').allMatches(textContent).length;
            
            print('🔍 DEBUG: Data density analysis:');
            print('🔍 DEBUG: Statistics found: $statisticsCount');
            print('🔍 DEBUG: Chart elements: $chartElements');
            print('🔍 DEBUG: Data points: $dataPoints');
            print('🔍 DEBUG: Total images used: ${imageSources.length}');
            
            if (imageSources.length <= 3 && statisticsCount >= 20) {
              print('🔍 DEBUG: Excellent - Minimal images with high data density!');
            } else if (imageSources.length <= 5 && statisticsCount >= 15) {
              print('🔍 DEBUG: Good - Balanced images and data content');
            } else if (imageSources.length > 5) {
              print('🔍 DEBUG: WARNING - Too many images, focus on data density!');
            } else {
              print('🔍 DEBUG: INFO - Current image and data balance');
            }
          }
          // final jsonData = json.decode(cleanedResponse);
          // return InfographicModel(
          //   htmlCode: (jsonData['html'] as List).first ?? '',
          //   cssCode: (jsonData['css'] as List).first ?? '',
          //   prompt: prompt,
          // );
          // Debug logging for final result
          print('🔍 DEBUG: Creating InfographicModel with parsed data');
          final finalHtml = (jsonData['html'] is List)
              ? (jsonData['html'] as List).join("\n")
              : (jsonData['html'] ?? '');
          final finalCss = (jsonData['css'] is List)
              ? (jsonData['css'] as List).join("\n")
              : (jsonData['css'] ?? '');
          
          print('🔍 DEBUG: Final HTML length: ${finalHtml.length}');
          print('🔍 DEBUG: Final CSS length: ${finalCss.length}');
          print('🔍 DEBUG: Infographic generation completed successfully');
          
        return InfographicModel(
          htmlCode: finalHtml,
          cssCode: finalCss,
          prompt: prompt,
        );
      } catch (e) {
        print('🔍 DEBUG: JSON parsing error occurred: $e');
        print('🔍 DEBUG: Error type: ${e.runtimeType}');
        dp.log('JSON parsing error: $e');
        // dp.log('Response: $cleanedResponse');
        return null;
      }
    }
    return null;
      } catch (e) {
        // Check if it's a 503 error (service overloaded)
        if (e is GenerativeAIException && e.toString().contains('503')) {
          print('🔍 DEBUG: 503 Service Unavailable error on attempt $attempt');
          
          if (attempt < maxRetries) {
            // Calculate exponential backoff delay
            final delay = Duration(
              seconds: baseDelay.inSeconds * (attempt * attempt), // Exponential backoff: 2s, 8s, 18s
            );
            
            print('🔍 DEBUG: Retrying in ${delay.inSeconds} seconds...');
            
            // Show snackbar notification
            Get.snackbar(
              "Service Busy",
              "AI is overloaded right now. Retrying in ${delay.inSeconds} seconds...",
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: delay.inSeconds.clamp(1, 10)), // Show for max 10 seconds
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade800,
            );
            
            // Wait before retrying
            await Future.delayed(delay);
            continue; // Try again
          } else {
            // Max retries reached
            print('🔍 DEBUG: Max retries reached for 503 error');
            Get.snackbar(
              "Service Busy",
              "AI is overloaded right now. Please try again in a few seconds.",
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
            );
          }
        }
        
        // For other errors or max retries reached
        print('🔍 DEBUG: Error occurred during infographic generation: $e');
        print('🔍 DEBUG: Error type: ${e.runtimeType}');
        print('🔍 DEBUG: Stack trace: ${StackTrace.current}');
        dp.log('Error generating infographic: $e');
        
        if (attempt == maxRetries) {
          Get.snackbar(
            "Error",
            "Failed to generate infographic after $maxRetries attempts. Please try again.",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
          );
        }
        
        return null;
      }
    }
    
    return null; // This should never be reached due to the loop structure
  }

  // Debug helper methods for keyword detection
  bool _containsCricketKeywords(String prompt) {
    final cricketKeywords = [
      'cricket', 'world cup', 'stadium', 'players', 'bat', 'ball', 'wicket',
      '1992', '1996', '1999', '2003', '2007', '2011', '2015', '2019', '2023',
      'pakistan', 'india', 'australia', 'england', 'south africa', 'sri lanka',
      'west indies', 'bangladesh', 'new zealand', 'afghanistan', 'ireland'
    ];
    return cricketKeywords.any((keyword) => prompt.toLowerCase().contains(keyword));
  }

  bool _containsFoodKeywords(String prompt) {
    final foodKeywords = [
      'food', 'biryani', 'curry', 'rice', 'chicken', 'beef', 'mutton',
      'kolkata', 'lucknowi', 'hyderabadi', 'mumbai', 'delhi', 'indian',
      'pakistani', 'cuisine', 'cooking', 'recipe', 'restaurant', 'kitchen'
    ];
    return foodKeywords.any((keyword) => prompt.toLowerCase().contains(keyword));
  }

  bool _containsCountryKeywords(String prompt) {
    final countryKeywords = [
      'pakistan', 'india', 'usa', 'united states', 'china', 'japan', 'germany',
      'france', 'uk', 'united kingdom', 'canada', 'australia', 'brazil',
      'russia', 'country', 'nation', 'flag', 'population', 'economy'
    ];
    return countryKeywords.any((keyword) => prompt.toLowerCase().contains(keyword));
  }

  bool _containsTechKeywords(String prompt) {
    final techKeywords = [
      'ai', 'artificial intelligence', 'technology', 'blockchain', 'crypto',
      'machine learning', 'data science', 'programming', 'software', 'app',
      'digital', 'cyber', 'robot', 'automation', 'innovation', 'tech'
    ];
    return techKeywords.any((keyword) => prompt.toLowerCase().contains(keyword));
  }

  String _getExpectedImageType(String prompt) {
    if (_containsCricketKeywords(prompt)) return 'CRICKET/SPORTS';
    if (_containsFoodKeywords(prompt)) return 'FOOD/CUISINE';
    if (_containsCountryKeywords(prompt)) return 'COUNTRY/GEOGRAPHY';
    if (_containsTechKeywords(prompt)) return 'TECHNOLOGY/AI';
    return 'GENERAL';
  }
}
