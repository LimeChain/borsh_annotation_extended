import 'dart:typed_data';

import 'package:borsh_annotation/borsh_annotation.dart';

const _initialLength = 1024;
final _byteMask = BigInt.from(0xff);

class ExtendedBinaryWriter extends BinaryWriter {
  late BinaryWriter _baseWriter;
  
  ExtendedBinaryWriter() : super();

  factory ExtendedBinaryWriter.fromBinaryWriter(BinaryWriter writer) {
    final extended = ExtendedBinaryWriter();
    extended._baseWriter = writer;
    return extended;
  }

  @override
  ByteData get buf => _baseWriter.buf;
  
  @override
  set buf(ByteData value) => _baseWriter.buf = value;
  
  @override
  int get length => _baseWriter.length;
  
  @override
  set length(int value) => _baseWriter.length = value;
  void writeU128(BigInt value) {
    final buffer = _encodeBigIntAsUnsigned(value, 16);
    _writeBuffer(buffer);
  }

  void writeF32(double value) {
    _maybeResize();
    _baseWriter.buf.setFloat32(_baseWriter.length, value, Endian.little);
    _baseWriter.length += 4;
  }

  void writeF64(double value) {
    _maybeResize();
    _baseWriter.buf.setFloat64(_baseWriter.length, value, Endian.little);
    _baseWriter.length += 8;
  }

  void _writeBuffer(Iterable<int> buffer) {
    final list = Uint8List.fromList([
      ..._baseWriter.buf.buffer.asUint8List().take(_baseWriter.length),
      ...buffer,
      ...Uint8List(_initialLength),
    ]);
    _baseWriter.buf = list.buffer.asByteData();
    _baseWriter.length += buffer.length;
  }

  Iterable<int> _encodeBigIntAsUnsigned(BigInt number, int s) {
    BigInt n = number;
    if (n == BigInt.zero) {
      return List.filled(s, 0);
    }
    final result = Uint8List(s);
    for (int i = 0; i < s; i++) {
      result[i] = (n & _byteMask).toInt();
      n = n >> 8;
    }
    return result;
  }

  void _maybeResize() {
    if (_baseWriter.buf.lengthInBytes >= 16 + _baseWriter.length) return;
    final list = Uint8List.fromList([
      ..._baseWriter.buf.buffer.asUint8List(),
      ...Uint8List(_initialLength),
    ]);
    _baseWriter.buf = list.buffer.asByteData();
  }
}
