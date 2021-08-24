import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:process/process.dart';
import 'wrapped_process.dart';

/// Wrapper over `package:process` [Process] API's that supports features like environment management, user switches, and more.
class Shell {
  final ProcessManager processManager;
  final Map<String, String> environment = {};
  bool includeParentEnvironment, sudo;
  String? workingDirectory;
  String? username, password;
  bool runInShell;

  Shell(
      {this.processManager: const LocalProcessManager(),
      this.includeParentEnvironment: true,
      this.workingDirectory,
      this.sudo: false,
      this.runInShell: true,
      this.username,
      this.password,
      Map<String, String> environment: const {}}) {
    this.environment.addAll(environment);
    workingDirectory ??= p.absolute(p.current);
  }

  factory Shell.copy(Shell other) {
    return new Shell(
        environment: other.environment,
        processManager: other.processManager,
        includeParentEnvironment: other.includeParentEnvironment,
        workingDirectory: other.workingDirectory,
        sudo: other.sudo,
        runInShell: other.runInShell,
        username: other.username,
        password: other.password);
  }

  void navigate(String path) {
    if (workingDirectory == null) {
      workingDirectory = path;
    } else {
      workingDirectory = p.join(workingDirectory!, path);
    }

    workingDirectory = p.absolute(workingDirectory!);
  }

  Future<ProcessResult> run(String executable,
      {Iterable<String> arguments = const []}) {
    var command = [executable]..addAll(arguments);
    if (sudo)
      throw new UnsupportedError(
          'When using `sudo`, you cannot call `run`, as stdin access is required to provide an account password.');
    return processManager.run(command,
        workingDirectory: workingDirectory,
        environment: environment,
        runInShell: runInShell,
        includeParentEnvironment: includeParentEnvironment);
  }

  Future<WrappedProcess> start(String executable,
      {Iterable<String> arguments = const []}) async {
    var command = [executable]..addAll((arguments));

    if (sudo || username != null) {
      // sudo -k -p ''
      var sudoArgs = ['sudo', '-k', '-p', ''];
      if (username != null) sudoArgs.addAll(['-u', username!]);
      if (password != null) sudoArgs.add('-S');
      command.insertAll(0, sudoArgs);
    }

    var p = await processManager.start(command,
        workingDirectory: workingDirectory,
        environment: environment,
        runInShell: runInShell,
        includeParentEnvironment: includeParentEnvironment);
    if ((sudo || username != null) && password != null)
      p.stdin.writeln(password);
    return new WrappedProcess(command.first, command.skip(1), p);
  }

  Future<String> startAndReadAsString(String executable,
      {Iterable<String> arguments = const [],
      Encoding encoding: utf8,
      List<int> acceptedExitCodes: const [0]}) async {
    var p = await start(executable, arguments: arguments);
    await p.expectExitCode(acceptedExitCodes);
    return await p.stdout.readAsString(encoding: encoding);
  }
}
