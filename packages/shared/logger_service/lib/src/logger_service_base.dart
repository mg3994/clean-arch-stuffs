enum LogLevel { debug, info, warning, error }

abstract class LoggerService {
  void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace});
  void debug(String message);
  void info(String message);
  void warning(String message);
  void error(String message, {Object? error, StackTrace? stackTrace});
}

class ConsoleLoggerService implements LoggerService {
  final String prefix;
  final List<String> logs = [];

  ConsoleLoggerService({this.prefix = 'APP'});

  @override
  void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    final entry = '[$prefix] [${level.name.toUpperCase()}] $message';
    logs.add(entry);
  }

  @override
  void debug(String message) => log(message, level: LogLevel.debug);

  @override
  void info(String message) => log(message, level: LogLevel.info);

  @override
  void warning(String message) => log(message, level: LogLevel.warning);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
}
