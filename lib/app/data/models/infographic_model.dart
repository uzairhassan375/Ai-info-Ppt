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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Infographic</title>
    <style>
        $cssCode
    </style>
</head>
<body>
    $htmlCode
</body>
</html>
''';
}
