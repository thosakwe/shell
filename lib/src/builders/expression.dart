import 'builder.dart';
import 'package:indenting_buffer/indenting_buffer.dart';
import 'file_descriptor.dart';

/// Compiles to a shell script expression, context-free.
abstract class ExpressionBuilder implements AstBuilder {
  /// Compiles this expression.
  String compileExpression();

  @override
  void compile(IndentingBuffer buffer) {
    buffer.writeln(compileExpression());
  }

  /// Executes another expression after this one.
  ///
  /// This is best modeled as `a && b`.
  ExpressionBuilder then(ExpressionBuilder expression);

  /// Wraps this expression builder in parentheses.
  ExpressionBuilder parentheses();

  /// Pipes the output of this process into another's stdin.
  ExpressionBuilder pipe(ExpressionBuilder expression);

  /// Pipes the stderr output of this process into another's stdin.
  ExpressionBuilder pipeStderr(ExpressionBuilder expression);

  /// Redirects output from this process to a file descriptor.
  ExpressionBuilder redirect(FileDescriptorBuilder descriptor,
      {bool append, bool stdout, bool stderr});
}
