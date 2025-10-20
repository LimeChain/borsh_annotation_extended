import 'dart:typed_data';

import 'package:borsh_annotation/borsh_annotation.dart';

class ExtendedBinaryReader extends BinaryReader {
  late BinaryReader _baseReader;

  ExtendedBinaryReader._(super.buf);

  factory ExtendedBinaryReader.fromBinaryReader(BinaryReader reader) {
    final extended = ExtendedBinaryReader._(reader.buf);
    extended._baseReader = reader;
    extended.offset = reader.offset;
    return extended;
  }

  @override
  ByteData get buf => _baseReader.buf;

  @override
  int get offset => _baseReader.offset;

  @override
  set offset(int value) => _baseReader.offset = value;

  BigInt readU128() {
    final buffer = _readBuffer(16);

    return _decodeBigInt(buffer);
  }

  BigInt readI128() {
    final buffer = _readBuffer(16);

    return _decodeBigIntSigned(buffer, 16);
  }

  BigInt readI64() {
    final buffer = _readBuffer(8);

    return _decodeBigIntSigned(buffer, 8);
  }

  int readI32() {
    final value = _baseReader.buf.getInt32(_baseReader.offset, Endian.little);
    _baseReader.offset += 4;

    return value;
  }

  int readI16() {
    final value = _baseReader.buf.getInt16(_baseReader.offset, Endian.little);
    _baseReader.offset += 2;

    return value;
  }

  int readI8() {
    final value = _baseReader.buf.getInt8(_baseReader.offset);
    _baseReader.offset += 1;

    return value;
  }

  double readF32() {
    final value = _baseReader.buf.getFloat32(_baseReader.offset, Endian.little);
    _baseReader.offset += 4;

    return value;
  }

  double readF64() {
    final value = _baseReader.buf.getFloat64(_baseReader.offset, Endian.little);
    _baseReader.offset += 8;

    return value;
  }

  List<int> _readBuffer(int len) {
    if (_baseReader.offset + len > _baseReader.buf.lengthInBytes) {
      throw RangeError('Buffer overflow');
    }
    final buffer = _baseReader.buf.buffer.asUint8List().sublist(
      _baseReader.offset,
      _baseReader.offset + len,
    );
    _baseReader.offset += len;

    return buffer;
  }

  BigInt _decodeBigInt(Iterable<int> bytes) {
    final list = bytes.toList();
    BigInt result = BigInt.zero;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      result |= BigInt.from(item) << (8 * i);
    }

    return result;
  }

  BigInt _decodeBigIntSigned(Iterable<int> bytes, int sizeInBytes) {
    final list = bytes.toList();
    BigInt result = BigInt.zero;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      result |= BigInt.from(item) << (8 * i);
    }

    final signBit = BigInt.one << (sizeInBytes * 8 - 1);
    if (result & signBit != BigInt.zero) {
      final maxValue = BigInt.one << (sizeInBytes * 8);
      result = result - maxValue;
    }

    return result;
  }
}
