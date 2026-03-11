import 'package:flutter/foundation.dart';

const String prodApiBaseUrl = 'https://fastapi-openrouter-api.onrender.com';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: prodApiBaseUrl);
