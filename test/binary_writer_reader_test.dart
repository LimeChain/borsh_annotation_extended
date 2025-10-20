import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:borsh_annotation_extended/src/binary_writer.dart';
import 'package:borsh_annotation_extended/src/binary_reader.dart';

void main() {
  group('Property override tests:', () {
    test('ExtendedBinaryWriter getter/setter overrides', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      final newBuf = ByteData(100);
      writer.buf = newBuf;
      expect(writer.buf, newBuf);

      writer.length = 42;
      expect(writer.length, 42);
    });

    test('ExtendedBinaryReader getter override', () {
      final data = Uint8List.fromList([1, 2, 3, 4]);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      expect(reader.buf, baseReader.buf);
    });
  });

  group('ExtendedBinaryWriter tests:', () {
    test('writeU128 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = BigInt.parse('340282366920938463463374607431768211455');

      writer.writeU128(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      expect(data.length, 16);
    });

    test('writeF32 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = 3.14159;

      writer.writeF32(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      expect(data.length, 4);
    });

    test('writeF64 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = 2.718281828459045;

      writer.writeF64(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      expect(data.length, 8);
    });

    test('fromBinaryWriter preserves state', () {
      final baseWriter = BinaryWriter();
      baseWriter.writeU8(42);

      final extendedWriter = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      extendedWriter.writeF32(3.14);

      expect(baseWriter.length, greaterThan(4));
    });
  });

  group('ExtendedBinaryReader tests:', () {
    test('readU128 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = BigInt.parse('123456789012345678901234567890');
      writer.writeU128(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final readValue = reader.readU128();
      expect(readValue, testValue);
    });

    test('readF32 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = 3.14159;
      writer.writeF32(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final readValue = reader.readF32();
      expect(readValue, closeTo(testValue, 0.0001));
    });

    test('readF64 functionality', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
      final testValue = 2.718281828459045;
      writer.writeF64(testValue);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final readValue = reader.readF64();
      expect(readValue, testValue);
    });

    test('fromBinaryReader preserves state', () {
      final data = Uint8List.fromList([42, 0, 0, 0]);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final firstByte = baseReader.readU8();

      final extendedReader = ExtendedBinaryReader.fromBinaryReader(baseReader);
      expect(extendedReader.offset, 1);
      expect(firstByte, 42);
    });
  });

  group('Round-trip tests:', () {
    test('U128 round-trip', () {
      final testValues = [
        BigInt.zero,
        BigInt.one,
        BigInt.parse('340282366920938463463374607431768211455'),
        BigInt.parse('123456789012345678901234567890'),
      ];

      for (final value in testValues) {
        final baseWriter = BinaryWriter();
        final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);
        writer.writeU128(value);

        final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
        final baseReader = BinaryReader(ByteData.sublistView(data));
        final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

        final readValue = reader.readU128();
        expect(readValue, value, reason: 'Failed for value: $value');
      }
    });

    test('Mixed types round-trip', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      // Write mixed data
      writer.writeU128(BigInt.parse('123456789012345'));
      writer.writeF32(3.14);
      writer.writeF64(2.718281828459045);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final u128Value = reader.readU128();
      final f32Value = reader.readF32();
      final f64Value = reader.readF64();

      expect(u128Value, BigInt.parse('123456789012345'));
      expect(f32Value, closeTo(3.14, 0.01));
      expect(f64Value, 2.718281828459045);
    });
  });

  group('Error handling tests:', () {
    test('buffer overflow in readBuffer', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      expect(() => reader.readU128(), throwsA(isA<RangeError>()));
    });

    test('buffer resize in writer', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      for (int i = 0; i < 100; i++) {
        writer.writeU128(BigInt.from(i));
      }

      expect(writer.length, 1600);
      expect(writer.buf.lengthInBytes, greaterThan(1600));
    });
  });

  group('Edge case tests for internal logic:', () {
    test('small buffer edge case for single byte handling', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      writer.writeU128(BigInt.from(255));

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final result = reader.readU128();
      expect(result, BigInt.from(255));
    });

    test('zero value in U128', () {
      final baseWriter = BinaryWriter();
      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      writer.writeU128(BigInt.zero);

      final data = writer.buf.buffer.asUint8List().sublist(0, writer.length);
      final baseReader = BinaryReader(ByteData.sublistView(data));
      final reader = ExtendedBinaryReader.fromBinaryReader(baseReader);

      final result = reader.readU128();
      expect(result, BigInt.zero);
    });

    test('force buffer resize scenario', () {
      final baseWriter = BinaryWriter();
      baseWriter.buf = ByteData(10);
      baseWriter.length = 0;

      final writer = ExtendedBinaryWriter.fromBinaryWriter(baseWriter);

      writer.writeF64(1.23456789);
      writer.writeF64(2.3456789);

      expect(writer.length, 16);
      expect(writer.buf.lengthInBytes, greaterThan(16));
    });
  });
}
