import 'dart:typed_data';
import 'package:test/test.dart';
import 'data.dart';

void main() {
  group('extended types:', () {
    test('serializes and deserializes new types', () {
      final struct = StructWithNewTypes(
        u128Value: BigInt.parse(
          '340282366920938463463374607431768211455',
        ), // max u128
        f32Value: 3.14159,
        f64Value: 2.718281828459045,
        bytesValue: Uint8List.fromList([1, 2, 3, 4, 5]),
        fixedBytesValue: Uint8List.fromList(List.generate(32, (i) => i + 1)),
      );

      final serialized = struct.toBorsh();
      final deserialized = StructWithNewTypes.fromBorsh(serialized);

      expect(deserialized.u128Value, struct.u128Value);
      expect(deserialized.f32Value, closeTo(struct.f32Value, 0.0001));
      expect(deserialized.f64Value, struct.f64Value);
      expect(deserialized.bytesValue, struct.bytesValue);
      expect(deserialized.fixedBytesValue, struct.fixedBytesValue);
    });

    test('u128 edge cases', () {
      final testCases = [
        BigInt.zero,
        BigInt.one,
        BigInt.parse('340282366920938463463374607431768211455'),
      ];

      for (final value in testCases) {
        final struct = StructWithNewTypes(
          u128Value: value,
          f32Value: 1.0,
          f64Value: 1.0,
          bytesValue: Uint8List.fromList([1]),
          fixedBytesValue: Uint8List.fromList(List.filled(32, 0)),
        );

        final serialized = struct.toBorsh();
        final deserialized = StructWithNewTypes.fromBorsh(serialized);

        expect(deserialized.u128Value, value);
      }
    });

    test('unsigned types convert negative values (legacy behavior)', () {
      // Test that unsigned types still convert negative to positive (for backward compatibility)
      // Note: Use signed types (BI64, BI128) for proper negative value handling

      // BU64 converts -1 to max uint64
      final bu64Struct = Test1(
        stringValue: "test",
        intValue: 42,
        bigIntValue: -BigInt.one,
        listOfStrings: ["a", "b", "c"],
        listOfInts: [1, 2, 3],
        listOfListsOfInts: [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
        dynamicListOfStrings: ["x", "y", "z"],
      );
      final bu64Serialized = bu64Struct.toBorsh();
      final bu64Deserialized = Test1.fromBorsh(bu64Serialized);
      expect(
        bu64Deserialized.bigIntValue,
        BigInt.parse('18446744073709551615'),
      );

      // BU128 converts -1 to max uint128
      final bu128Struct = StructWithNewTypes(
        u128Value: -BigInt.one,
        f32Value: 1.0,
        f64Value: 1.0,
        bytesValue: Uint8List.fromList([1]),
        fixedBytesValue: Uint8List.fromList(List.filled(32, 0)),
      );
      final bu128Serialized = bu128Struct.toBorsh();
      final bu128Deserialized = StructWithNewTypes.fromBorsh(bu128Serialized);
      expect(
        bu128Deserialized.u128Value,
        BigInt.parse('340282366920938463463374607431768211455'),
      );
    });

    test('float precision and edge cases', () {
      final testCases = [
        // (f32, f64, description)
        (1.23456789, 1.23456789012345, 'precision'),
        (-3.14159, -2.718281828459045, 'negative'),
        (3.4028235e+38, double.maxFinite, 'extreme values'),
      ];

      for (final (f32, f64, description) in testCases) {
        final struct = StructWithNewTypes(
          u128Value: BigInt.zero,
          f32Value: f32,
          f64Value: f64,
          bytesValue: Uint8List.fromList([1]),
          fixedBytesValue: Uint8List.fromList(List.filled(32, 0)),
        );

        final serialized = struct.toBorsh();
        final deserialized = StructWithNewTypes.fromBorsh(serialized);

        if (description == 'precision') {
          expect(deserialized.f32Value, closeTo(1.2345679, 0.0000001));
          expect(deserialized.f64Value, f64);
        } else if (description == 'extreme values') {
          expect(deserialized.f32Value.isFinite, true);
          expect(deserialized.f64Value, f64);
        } else {
          expect(deserialized.f32Value, closeTo(f32, 0.0001));
          expect(deserialized.f64Value, f64);
        }
      }
    });

    test('bytes edge cases', () {
      // Empty bytes
      final emptyStruct = StructWithNewTypes(
        u128Value: BigInt.zero,
        f32Value: 1.0,
        f64Value: 1.0,
        bytesValue: Uint8List.fromList([]),
        fixedBytesValue: Uint8List.fromList(List.filled(32, 0)),
      );
      final emptySerialized = emptyStruct.toBorsh();
      final emptyDeserialized = StructWithNewTypes.fromBorsh(emptySerialized);
      expect(emptyDeserialized.bytesValue.length, 0);
      expect(emptyDeserialized.fixedBytesValue.length, 32);
    });

    test('large bytes arrays', () {
      final largeBytesValue = Uint8List.fromList(
        List.generate(1000, (i) => i % 256),
      );

      final struct = StructWithNewTypes(
        u128Value: BigInt.zero,
        f32Value: 1.0,
        f64Value: 1.0,
        bytesValue: largeBytesValue,
        fixedBytesValue: Uint8List.fromList(List.generate(32, (i) => 255 - i)),
      );

      final serialized = struct.toBorsh();
      final deserialized = StructWithNewTypes.fromBorsh(serialized);

      expect(deserialized.bytesValue.length, 1000);
      expect(deserialized.bytesValue, largeBytesValue);
      expect(deserialized.fixedBytesValue[0], 255);
      expect(deserialized.fixedBytesValue[31], 224);
    });
  });

  group('BFixedArray tests:', () {
    test('fixed array serialization with custom BFixedArray', () {
      final struct = Test1(
        stringValue: "test",
        intValue: 42,
        bigIntValue: BigInt.from(123456789),
        listOfStrings: ["a", "b", "c"],
        listOfInts: [1, 2, 3],
        listOfListsOfInts: [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
        dynamicListOfStrings: ["x", "y", "z"],
      );

      final serialized = struct.toBorsh();
      final deserialized = Test1.fromBorsh(serialized);

      expect(deserialized.listOfStrings, ["a", "b", "c"]);
      expect(deserialized.listOfInts, [1, 2, 3]);
      expect(deserialized.listOfListsOfInts, [
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
    });
  });

  group('Error handling:', () {
    test('BFixedBytes length validation during serialization', () {
      final struct = StructWithNewTypes(
        u128Value: BigInt.zero,
        f32Value: 1.0,
        f64Value: 1.0,
        bytesValue: Uint8List.fromList([1]),
        fixedBytesValue: Uint8List.fromList([1, 2, 3]),
      );

      expect(() => struct.toBorsh(), throwsA(isA<ArgumentError>()));
    });

    test('BFixedArray length validation during write', () {
      final struct = Test1(
        stringValue: "test",
        intValue: 42,
        bigIntValue: BigInt.from(123),
        listOfStrings: ["a", "b"],
        listOfInts: [1, 2, 3],
        listOfListsOfInts: [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
        dynamicListOfStrings: ["x", "y"],
      );

      expect(() => struct.toBorsh(), throwsA(isA<ArgumentError>()));
    });
  });

  group('Signed integer types:', () {
    test('signed integer types handle all value ranges', () {
      final testCases = [
        // (i128, i64, i32, i16, i8, description)
        (BigInt.zero, BigInt.zero, 0, 0, 0, 'zero values'),
        (-BigInt.one, -BigInt.one, -1, -1, -1, 'negative one'),
        (
          BigInt.parse('-123456789'),
          BigInt.parse('-123456789'),
          -123456789,
          -12345,
          -123,
          'arbitrary negative',
        ),
        (
          BigInt.parse('-170141183460469231731687303715884105728'),
          BigInt.parse('-9223372036854775808'),
          -2147483648,
          -32768,
          -128,
          'minimum values',
        ),
        (
          BigInt.parse('170141183460469231731687303715884105727'),
          BigInt.parse('9223372036854775807'),
          2147483647,
          32767,
          127,
          'maximum values',
        ),
      ];

      for (final (i128, i64, i32, i16, i8, description) in testCases) {
        final struct = StructWithSignedTypes(
          i128Value: i128,
          i64Value: i64,
          i32Value: i32,
          i16Value: i16,
          i8Value: i8,
        );

        final serialized = struct.toBorsh();
        final deserialized = StructWithSignedTypes.fromBorsh(serialized);

        expect(
          deserialized.i128Value,
          i128,
          reason: 'i128 failed for $description',
        );
        expect(
          deserialized.i64Value,
          i64,
          reason: 'i64 failed for $description',
        );
        expect(
          deserialized.i32Value,
          i32,
          reason: 'i32 failed for $description',
        );
        expect(
          deserialized.i16Value,
          i16,
          reason: 'i16 failed for $description',
        );
        expect(deserialized.i8Value, i8, reason: 'i8 failed for $description');
      }
    });
  });
}
