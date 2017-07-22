import 'package:indenting_buffer/indenting_buffer.dart';

/// Compiles to a native shell script block.
abstract class AstBuilder {
  /// Writes content to a buffer, unaware of its indentation level.
  void compile(IndentingBuffer buffer);
}