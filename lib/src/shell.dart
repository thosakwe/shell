import 'dart:async';
import 'builders/shell_script.dart';

abstract class Shell {
  /// Creates a new [ShellScript].
  ShellScript newScript();

  /// Runs the given [script].
  Future runScript(ShellScript script);
}