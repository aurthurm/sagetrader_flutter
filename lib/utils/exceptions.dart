void handleTimeOutException(error) {
  if (error.toString().contains('TimeoutException')) {
      throw NetworkTimeOutException('Try Again');
  }
}

void handleSocketException(error) {
  if (error.toString().contains('SocketException')) {
      throw NoConnectionException('Are you online?');
  }
}

void handleClientException(error) {
  if (error.toString().contains('ClientException')) {
      throw NoConnectionException('Are you online?');
  }
}

void fallbackExceptionHandler(error) {
  throw Exception("An Error Occured. Try Again");
}

void handleCommonExceptions(error) {
  handleTimeOutException(error);
  handleSocketException(error);
  handleClientException(error);
  fallbackExceptionHandler(error);
}


class MSPTException implements Exception {
  final message;
  final prefix;

  MSPTException(this.message, this.prefix);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends MSPTException {
  FetchDataException([String message]): super(message, "Communication Error: ");
}

class BadRequestException extends MSPTException {
  BadRequestException([String message]): super(message, "Invalid Request: ");
}

class UnauthorisedException extends MSPTException {
  UnauthorisedException([String message]): super(message, "Unauthorised: ");
}

class InvalidInputException extends MSPTException {
  InvalidInputException([String message]): super(message, "Invalid Input: ");
}

class NoConnectionException extends MSPTException {
  NoConnectionException([String message]): super(message, "No Connection: ");
}

class NoInternetException extends MSPTException {
  NoInternetException([String message]): super(message, "No Internet: ");
}

class NetworkTimeOutException extends MSPTException {
  NetworkTimeOutException([String message]): super(message, "Network Timeout: ");
}

class UnknownException extends MSPTException {
  UnknownException([String message]): super(message, "We are Sorry: ");
}


class PersistException implements Exception {
  String message;

  PersistException(this.message);

  @override
  String toString() {
    return this.message;
  }
}