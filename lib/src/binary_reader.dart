import 'dart:typed_data';

import 'package:borsh_annotation/borsh_annotation.dart';

const _negativeFlag = 0x80;

class ExtendedBinaryReader extends BinaryReader {
  late BinaryReader _baseReader;
  
  ExtendedBinaryReader(super.buf);

  factory ExtendedBinaryReader.fromBinaryReader(BinaryReader reader) {
    final extended = ExtendedBinaryReader(reader.buf);
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

    return _decodeBigInt(buffer, isSigned: false);
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
    final buffer = _baseReader.buf.buffer.asUint8List().sublist(_baseReader.offset, _baseReader.offset + len);
    _baseReader.offset += len;

    return buffer;
  }

  BigInt _decodeBigInt(Iterable<int> bytes, {required bool isSigned}) {
    final list = bytes.toList();

    final negative = isSigned
        ? list.isNotEmpty && list.last & _negativeFlag == _negativeFlag
        : false;

    BigInt result;

    if (list.length == 1) {
      result = BigInt.from(list.first);
    } else {
      result = BigInt.zero;
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        result |= BigInt.from(item) << (8 * i);
      }
    }

    return result != BigInt.zero
        ? negative
              ? result.toSigned(result.bitLength)
              : result
        : BigInt.zero;
  }
}
