import 'package:flutter/foundation.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: kReleaseMode
        ? 'https://fastapi-openrouter-api.onrender.com'
        : 'http://localhost:8000');
