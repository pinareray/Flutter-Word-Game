import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Kaç fonksiyon çağrısı gösterilsin
    errorMethodCount: 5, // Hatalarda kaç çağrı gösterilsin
    lineLength: 100,
    colors: true,
  ),
);
