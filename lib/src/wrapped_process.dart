import 'dart:async';
import 'dart:convert';
import 'dart:io' show BytesBuilder, Process;
import 'package:file/file.dart';

class WrappedProcess {
  final Process process;
  final String executable;
  final Iterable<String> arguments;
  late WrappedProcessOutput _stdout, _stderr;

  WrappedProcess(this.executable, this.arguments, this.process) {
    _stdout = new WrappedProcessOutput(process, process.stdout);
    _stderr = new WrappedProcessOutput(process, process.stderr);
  }

  Future<int> get exitCode => process.exitCode;

  String get invocation =>
      arguments.isEmpty ? executable : '$executable ${arguments.join(' ')}';

  Future expectZeroExit() => expectExitCode(const [0]);

  Future expectExitCode(Iterable<int> acceptedCodes) async {
    var code = await exitCode;

    if (!acceptedCodes.contains(code))
      throw new StateError(
          '$invocation terminated with unexpected exit code $code.');
    else
      await stderr.drain();
  }

  int get pid => process.pid;

  IOSink get stdin => process.stdin;

  WrappedProcessOutput get stdout => _stdout;

  WrappedProcessOutput get stderr => _stderr;
}

class WrappedProcessOutput extends Stream<List<int>> {
  final Process _process;
  final Stream<List<int>> _stream;

  WrappedProcessOutput(this._process, this._stream);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<List<int>> readAsBytes() {
    return fold<BytesBuilder>(new BytesBuilder(), (bb, buf) => bb..add(buf))
        .then((bb) => bb.takeBytes());
  }

  Future<String> readAsString({Encoding encoding: utf8}) {
    return transform(encoding.decoder).join();
  }

  Future writeToFile(File file) {
    return _process.exitCode.then((_) => _stream.pipe(file.openWrite()));
  }
}
