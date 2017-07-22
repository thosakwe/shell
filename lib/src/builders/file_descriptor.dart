/// Represents a file descriptor that output can be redirected to.
abstract class FileDescriptorBuilder {
  /// Compiles this descriptor.
  String compile();
}