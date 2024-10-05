import 'package:tekartik_mustache/mustache_sync.dart';

/// Render not found content
String linkNotFoundContent(String link) {
  return render(notFoundContent, {'link': link});
}

/// Not found content
var notFoundContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Linkelio</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@100..900&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Lexend', Arial, sans-serif;
            background-color: #000000;
            color: #eeeeee;
        }
        .container {
            width: 960px;
            margin: 0 auto;
        }
    </style>
 </head>
<body>
<div class="container">
<h1>Linkelio</h1>
    <p>Link {{link}} not found</p>
</div>
</body>
</html>
''';
