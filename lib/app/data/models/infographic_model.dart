class InfographicModel {
  final String htmlCode;
  final String cssCode;
  final String prompt;

  InfographicModel({
    required this.htmlCode,
    required this.cssCode,
    required this.prompt,
  });

  factory InfographicModel.fromJson(Map<String, dynamic> json) {
    return InfographicModel(
      htmlCode: json['html'] ?? '',
      cssCode: json['css'] ?? '',
      prompt: json['prompt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'html': htmlCode,
      'css': cssCode,
      'prompt': prompt,
    };
  }

  String get combinedHtml => '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Infographic</title>
    <style>
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            padding: 0;
            width: 100vw;
            max-width: 100vw;
            overflow-x: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        $cssCode
    </style>
</head>
<body>
    $htmlCode
</body>
</html>
''';
}
