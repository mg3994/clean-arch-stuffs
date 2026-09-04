import 'package:flutter_test/flutter_test.dart';
import 'package:logger_service/logger_service.dart';

void main() {
  late ConsoleLoggerService logger;

  setUp(() {
    logger = ConsoleLoggerService(prefix: 'TEST');
  });

  test('logger logs messages with level and prefix', () {
    logger.info('User logged in successfully');
    logger.error('Failed to connect to backend');

    expect(logger.logs.length, 2);
    expect(logger.logs[0], contains('[TEST] [INFO] User logged in successfully'));
    expect(logger.logs[1], contains('[TEST] [ERROR] Failed to connect to backend'));
  });
}
