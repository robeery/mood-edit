enum AiErrorType {
  invalidRequest,
  authFailed,
  notFound,
  rateLimited,
  serverError,
  serviceUnavailable,
  deadlineExceeded,
  badResponse,
  unknown,
}

class AiException implements Exception {
  final AiErrorType type;
  final String message;
  final bool retryable;
  final int? statusCode;

  const AiException({
    required this.type,
    required this.message,
    this.retryable = false,
    this.statusCode,
  });

  factory AiException.fromStatusCode(int code, String body) {
    switch (code) {
      case 400:
        return AiException(
          type: AiErrorType.invalidRequest,
          message: 'Invalid request. The prompt may be malformed or the API key may be incorrect. ($code)',
          statusCode: code,
        );
      case 403:
        return AiException(
          type: AiErrorType.authFailed,
          message: 'Invalid API key. Check your settings. ($code)',
          statusCode: code,
        );
      case 404:
        return AiException(
          type: AiErrorType.notFound,
          message: 'Model not found. Try a different model. ($code)',
          statusCode: code,
        );
      case 429:
        return AiException(
          type: AiErrorType.rateLimited,
          message: 'Rate limit exceeded. Please retry once the limit resets. ($code)',
          statusCode: code,
        );
      case 500:
        return AiException(
          type: AiErrorType.serverError,
          message: 'Server error. Retrying... ($code)',
          retryable: true,
          statusCode: code,
        );
      case 503:
        return AiException(
          type: AiErrorType.serviceUnavailable,
          message: 'Service temporarily unavailable. Retrying... ($code)',
          retryable: true,
          statusCode: code,
        );
      case 504:
        return AiException(
          type: AiErrorType.deadlineExceeded,
          message: 'Request timed out. Retrying... ($code)',
          retryable: true,
          statusCode: code,
        );
      default:
        return AiException(
          type: AiErrorType.unknown,
          message: 'Unexpected error occurred. ($code)',
          statusCode: code,
        );
    }
  }

  @override
  String toString() => message;
}
