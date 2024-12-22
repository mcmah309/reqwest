class StatusCode {
  final int value;

  const StatusCode(this.value);

  @override
  String toString() => value.toString();

// canonical_reason // todo

  /// Check if status is within 400-499.
  bool isClientError() => value >= 400 && value < 500;

  /// Check if status is within 100-199.
  bool isInformational() => value >= 100 && value < 200;

  /// Check if status is within 300-399.
  bool isRedirection() => value >= 300 && value < 400;

  /// Check if status is within 500-599.
  bool isServerError() => value >= 500 && value < 600;

  /// Check if status is within 200-299.
  bool isSuccess() => value >= 200 && value < 300;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusCode && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

//************************************************************************//

// todo add constants
// ACCEPTED
// ALREADY_REPORTED
// BAD_GATEWAY
// BAD_REQUEST
// CONFLICT
// CONTINUE
// CREATED
// EXPECTATION_FAILED
// FAILED_DEPENDENCY
// FORBIDDEN
// FOUND
// GATEWAY_TIMEOUT
// GONE
// HTTP_VERSION_NOT_SUPPORTED
// IM_A_TEAPOT
// IM_USED
// INSUFFICIENT_STORAGE
// INTERNAL_SERVER_ERROR
// LENGTH_REQUIRED
// LOCKED
// LOOP_DETECTED
// METHOD_NOT_ALLOWED
// MISDIRECTED_REQUEST
// MOVED_PERMANENTLY
// MULTIPLE_CHOICES
// MULTI_STATUS
// NETWORK_AUTHENTICATION_REQUIRED
// NON_AUTHORITATIVE_INFORMATION
// NOT_ACCEPTABLE
// NOT_EXTENDED
// NOT_FOUND
// NOT_IMPLEMENTED
// NOT_MODIFIED
// NO_CONTENT
// OK
// PARTIAL_CONTENT
// PAYLOAD_TOO_LARGE
// PAYMENT_REQUIRED
// PERMANENT_REDIRECT
// PRECONDITION_FAILED
// PRECONDITION_REQUIRED
// PROCESSING
// PROXY_AUTHENTICATION_REQUIRED
// RANGE_NOT_SATISFIABLE
// REQUEST_HEADER_FIELDS_TOO_LARGE
// REQUEST_TIMEOUT
// RESET_CONTENT
// SEE_OTHER
// SERVICE_UNAVAILABLE
// SWITCHING_PROTOCOLS
// TEMPORARY_REDIRECT
// TOO_MANY_REQUESTS
// UNAUTHORIZED
// UNAVAILABLE_FOR_LEGAL_REASONS
// UNPROCESSABLE_ENTITY
// UNSUPPORTED_MEDIA_TYPE
// UPGRADE_REQUIRED
// URI_TOO_LONG
// USE_PROXY
// VARIANT_ALSO_NEGOTIATES
}