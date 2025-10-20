import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:borsh_annotation_extended/borsh_annotation_extended.dart';
import 'package:borsh_annotation_extended/src/binary_writer.dart';
import 'package:borsh_annotation_extended/src/binary_reader.dart';
import 'package:borsh_annotation/borsh_annotation.dart'
    as borsh_annotation
    show BFixedArray;

class BU128 extends BType<BigInt> {
  const BU128();

  @override
  void write(BinaryWriter writer, BigInt value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeU128(value);
  }

  @override
  BigInt read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readU128();
  }
}

class BI128 extends BType<BigInt> {
  const BI128();

  @override
  void write(BinaryWriter writer, BigInt value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeI128(value);
  }

  @override
  BigInt read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readI128();
  }
}

class BI64 extends BType<BigInt> {
  const BI64();

  @override
  void write(BinaryWriter writer, BigInt value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeI64(value);
  }

  @override
  BigInt read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readI64();
  }
}

class BI32 extends BType<int> {
  const BI32();

  @override
  void write(BinaryWriter writer, int value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeI32(value);
  }

  @override
  int read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readI32();
  }
}

class BI16 extends BType<int> {
  const BI16();

  @override
  void write(BinaryWriter writer, int value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeI16(value);
  }

  @override
  int read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readI16();
  }
}

class BI8 extends BType<int> {
  const BI8();

  @override
  void write(BinaryWriter writer, int value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeI8(value);
  }

  @override
  int read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readI8();
  }
}

class BF32 extends BType<double> {
  const BF32();

  @override
  void write(BinaryWriter writer, double value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeF32(value);
  }

  @override
  double read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readF32();
  }
}

class BF64 extends BType<double> {
  const BF64();

  @override
  void write(BinaryWriter writer, double value) {
    ExtendedBinaryWriter extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(
      writer,
    );
    extendedWriter.writeF64(value);
  }

  @override
  double read(BinaryReader reader) {
    ExtendedBinaryReader extendedReader = ExtendedBinaryReader.fromBinaryReader(
      reader,
    );
    return extendedReader.readF64();
  }
}

class BBytes extends BType<Uint8List> {
  const BBytes();

  @override
  void write(BinaryWriter writer, Uint8List value) {
    writer.writeArray<int>(value, (byte) => writer.writeU8(byte));
  }

  @override
  Uint8List read(BinaryReader reader) {
    return Uint8List.fromList(reader.readArray(() => reader.readU8()));
  }
}

class BFixedBytes extends BType<Uint8List> {
  const BFixedBytes(this.length);

  final int length;

  @override
  void write(BinaryWriter writer, Uint8List value) {
    if (value.length != length) {
      throw ArgumentError(
        'Expected Uint8List of length $length, got ${value.length}',
      );
    }
    writer.writeFixedArray<int>(value, (byte) => writer.writeU8(byte));
  }

  @override
  Uint8List read(BinaryReader reader) {
    return Uint8List.fromList(
      reader.readFixedArray(length, () => reader.readU8()),
    );
  }
}

class BFixedArray<T> extends borsh_annotation.BFixedArray<T> {
  const BFixedArray(super.length, super.type);

  @override
  void write(BinaryWriter writer, List<T> value) {
    if (value.length != length) {
      throw ArgumentError(
        'Expected List of length $length, got ${value.length}',
      );
    }
    writer.writeFixedArray<T>(value, (e) => type.write(writer, e));
  }
}
