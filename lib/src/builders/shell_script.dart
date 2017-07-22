import 'package:platform/platform.dart';
import 'package:shell/src/builders/builder.dart';
import 'package:shell/src/builders/expression.dart';
import 'package:shell/src/builders/file_descriptor.dart';

abstract class ShellScript {
  /// Compiles this shell script to a native equivalent.
  String compile();

  /// Defines a variable within this script.
  ExpressionBuilder define(String name, ExpressionBuilder value);

  /// Defines a local variable within this script.
  ExpressionBuilder defineLocal(String name, ExpressionBuilder value);

  /// Executes the given [expressions] concurrently.
  ///
  /// This is best modeled as `a & b`.
  ExpressionBuilder concurrent(Iterable<ExpressionBuilder> expressions);

  /// Runs a process on the system.
  ExpressionBuilder run(String path, [Iterable<String> arguments]);

  /// Returns a file descriptor allowing output to be redirected to a file.
  FileDescriptorBuilder file(String path);

  /// Builds a function within the given [name] and [parameters].
  void function(String name, Iterable<String> parameters, void build());
}

void daemon(ShellScript script) {
  script.function('daemon', [], () {
    script
        .run('echo')
        .redirect(script.file('/var/log/daemon.log'),
            stdout: true, stderr: true, append: true)
        .parentheses()
        .pipe(script.run('echo', [r'$!']));
  });

  script.run('daemon');
}
