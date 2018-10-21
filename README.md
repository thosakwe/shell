# shell
[![Pub](https://img.shields.io/pub/v/shell.svg)](https://pub.dartlang.org/packages/shell)

Wrapper over `dart:io` [Process] API's that supports features like environment management, user switches, and more.

Useful for writing shell utility scripts in Dart, or within applications that perform system administration
tasks on behalf of other users.

```dart
import 'dart:io';
import 'package:file/local.dart';
import 'package:shell/shell.dart';

main() async {
  var fs = const LocalFileSystem();
  var shell = new Shell();
  var password = Platform.environment['PASSWORD'];
  print('Password: $password');

  // Pipe results to files, easily.
  var echo = await shell.start('echo', ['hello world']);
  await echo.stdout.writeToFile(fs.file('hello.txt'));
  await echo.stderr.drain();

  // You can run a program, and expect a certain exit code.
  //
  // If a valid exit code is returned, stderr is drained, and
  // you don't have to manually.
  //
  // Otherwise, a StateError is thrown.
  var find = await shell.start('find', ['.']);
  await find.expectExitCode([0]); // Can also call find.expectZeroExit()

  // Dump outputs.
  print(await find.stdout.readAsString());

  // You can also run a process and immediately receive a string.
  var pwd = await shell.startAndReadAsString('pwd', []);
  print('cwd: $pwd');

  // Navigation allows you to `cd`.
  shell.navigate('./lib/src');
  pwd = await shell.startAndReadAsString('pwd', []);
  print('cwd: $pwd');

  // We can make a separate shell, with the same settings.
  var forked = new Shell.copy(shell)
    ..sudo = true
    ..password = password;

  // Say hi, as an admin!
  var superEcho = await forked.start('echo', ['hello, admin!']);
  await superEcho.expectExitCode([0, 1]);
  await superEcho.stdout.writeToFile(fs.file('hello_sudo.txt'));
}
```