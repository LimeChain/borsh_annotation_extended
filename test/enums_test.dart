import 'package:test/test.dart';
import 'package:borsh_annotation_extended/borsh_annotation_extended.dart';

// Simple variant classes that will match the factory constructor names
class VariantA {
  final int field0;
  final bool field1;

  const VariantA({required this.field0, required this.field1});

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    const BU32().write(writer, field0);
    const BBool().write(writer, field1);
    return writer.toArray();
  }

  static VariantA fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final field0 = const BU32().read(reader);
    final field1 = const BBool().read(reader);
    return VariantA(field0: field0, field1: field1);
  }

  @override
  String toString() => 'VariantA(field0: $field0, field1: $field1)';
}

class BVariantA implements BType<VariantA> {
  const BVariantA();

  @override
  void write(BinaryWriter writer, VariantA value) {
    const BU32().write(writer, value.field0);
    const BBool().write(writer, value.field1);
  }

  @override
  VariantA read(BinaryReader reader) {
    return VariantA(
      field0: const BU32().read(reader),
      field1: const BBool().read(reader),
    );
  }
}

class VariantB {
  final String message;

  const VariantB({required this.message});

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    const BString().write(writer, message);
    return writer.toArray();
  }

  static VariantB fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final message = const BString().read(reader);
    return VariantB(message: message);
  }

  @override
  String toString() => 'VariantB(message: $message)';
}

class BVariantB implements BType<VariantB> {
  const BVariantB();

  @override
  void write(BinaryWriter writer, VariantB value) {
    const BString().write(writer, value.message);
  }

  @override
  VariantB read(BinaryReader reader) {
    return VariantB(message: const BString().read(reader));
  }
}

class VariantC {
  const VariantC();

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    return writer.toArray();
  }

  static VariantC fromBorsh(Uint8List data) {
    return VariantC();
  }

  @override
  String toString() => 'VariantC()';
}

class BVariantC implements BType<VariantC> {
  const BVariantC();

  @override
  void write(BinaryWriter writer, VariantC value) {
    // Unit variant has no data
  }

  @override
  VariantC read(BinaryReader reader) {
    return VariantC();
  }
}

// Main enum class
class ExampleEnum {
  final dynamic variant;
  final int discriminant;

  const ExampleEnum._(this.variant, this.discriminant);

  factory ExampleEnum.variantA(int field0, bool field1) {
    return ExampleEnum._(VariantA(field0: field0, field1: field1), 0);
  }

  factory ExampleEnum.variantB(String message) {
    return ExampleEnum._(VariantB(message: message), 1);
  }

  factory ExampleEnum.variantC() {
    return ExampleEnum._(VariantC(), 2);
  }

  @override
  String toString() => variant.toString();

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(discriminant);
    final variantBytes = variant.toBorsh();
    for (final byte in variantBytes) {
      writer.writeU8(byte);
    }
    return writer.toArray();
  }
}

// Additional test classes for edge cases
class NamedVariant {
  final String name;
  final int value;

  const NamedVariant({required this.name, required this.value});

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    const BString().write(writer, name);
    const BU32().write(writer, value);
    return writer.toArray();
  }

  static NamedVariant fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final name = const BString().read(reader);
    final value = const BU32().read(reader);
    return NamedVariant(name: name, value: value);
  }
}

class BNamedVariant implements BType<NamedVariant> {
  const BNamedVariant();

  @override
  void write(BinaryWriter writer, NamedVariant value) {
    const BString().write(writer, value.name);
    const BU32().write(writer, value.value);
  }

  @override
  NamedVariant read(BinaryReader reader) {
    return NamedVariant(
      name: const BString().read(reader),
      value: const BU32().read(reader),
    );
  }
}

class NamedEnum {
  final dynamic variant;
  final int discriminant;

  const NamedEnum._(this.variant, this.discriminant);

  factory NamedEnum.namedVariant({required String name, required int value}) {
    return NamedEnum._(NamedVariant(name: name, value: value), 0);
  }

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(discriminant);
    final variantBytes = variant.toBorsh();
    for (final byte in variantBytes) {
      writer.writeU8(byte);
    }
    return writer.toArray();
  }
}

class IncompleteVariant {
  final String onlyField;

  const IncompleteVariant(this.onlyField);

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    const BString().write(writer, onlyField);
    return writer.toArray();
  }

  static IncompleteVariant fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final onlyField = const BString().read(reader);
    return IncompleteVariant(onlyField);
  }
}

class BIncompleteVariant implements BType<IncompleteVariant> {
  const BIncompleteVariant();

  @override
  void write(BinaryWriter writer, IncompleteVariant value) {
    const BString().write(writer, value.onlyField);
  }

  @override
  IncompleteVariant read(BinaryReader reader) {
    return IncompleteVariant(const BString().read(reader));
  }
}

class IncompleteEnum {
  final dynamic variant;
  final int discriminant;

  const IncompleteEnum._(this.variant, this.discriminant);

  // This factory expects two parameters but variant only has one field
  factory IncompleteEnum.incompleteVariant(String field1, String missingField) {
    return IncompleteEnum._(IncompleteVariant(field1), 0);
  }

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(discriminant);
    final variantBytes = variant.toBorsh();
    for (final byte in variantBytes) {
      writer.writeU8(byte);
    }
    return writer.toArray();
  }
}

class OrphanVariant {
  final String data;

  const OrphanVariant(this.data);

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    const BString().write(writer, data);
    return writer.toArray();
  }

  static OrphanVariant fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final dataField = const BString().read(reader);
    return OrphanVariant(dataField);
  }
}

class BOrphanVariant implements BType<OrphanVariant> {
  const BOrphanVariant();

  @override
  void write(BinaryWriter writer, OrphanVariant value) {
    const BString().write(writer, value.data);
  }

  @override
  OrphanVariant read(BinaryReader reader) {
    return OrphanVariant(const BString().read(reader));
  }
}

class OrphanEnum {
  final dynamic variant;
  final int discriminant;

  const OrphanEnum._(this.variant, this.discriminant);

  // Factory constructor that WON'T match OrphanVariant
  factory OrphanEnum.somethingElse(String data) {
    return OrphanEnum._(OrphanVariant(data), 0);
  }

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(discriminant);
    final variantBytes = variant.toBorsh();
    for (final byte in variantBytes) {
      writer.writeU8(byte);
    }
    return writer.toArray();
  }
}

void main() {
  group('Working BEnum Tests', () {
    test('should throw error for invalid discriminant', () {
      final enumType = BEnum<ExampleEnum>({
        VariantA: BVariantA(),
        VariantB: BVariantB(),
        VariantC: BVariantC(),
      });

      // Create invalid data with discriminant 5 (out of range 0-2)
      final invalidBytes = Uint8List.fromList([5, 0, 0, 0, 0]);
      final reader = BinaryReader(invalidBytes.buffer.asByteData());

      expect(
        () => enumType.read(reader),
        throwsA(
          isA<RangeError>().having(
            (e) => e.message,
            'message',
            contains('Invalid enum discriminant'),
          ),
        ),
      );
    });

    test('should handle class name with underscore prefix', () {
      // Create a variant with underscore prefix to test the _checkClassName logic
      final enumType = BEnum<ExampleEnum>({VariantA: BVariantA()});

      // This tests the className.startsWith('_') branch
      final original = ExampleEnum.variantA(42, false);

      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      final reader = BinaryReader(bytes.buffer.asByteData());
      final deserialized = enumType.read(reader);

      expect(deserialized.discriminant, equals(0));
      expect(deserialized.variant.field0, equals(42));
      expect(deserialized.variant.field1, equals(false));
    });

    test('should serialize and deserialize VariantA', () {
      final original = ExampleEnum.variantA(14, true);

      final enumType = BEnum<ExampleEnum>({
        VariantA: BVariantA(),
        VariantB: BVariantB(),
        VariantC: BVariantC(),
      });

      // Serialize
      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      print(
        'Serialized bytes: ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      // Deserialize
      final reader = BinaryReader(bytes.buffer.asByteData());
      final deserialized = enumType.read(reader);

      expect(deserialized.discriminant, equals(0));
      expect(deserialized.variant.field0, equals(14));
      expect(deserialized.variant.field1, equals(true));
    });

    test('should serialize and deserialize VariantB', () {
      final original = ExampleEnum.variantB('hello');

      final enumType = BEnum<ExampleEnum>({
        VariantA: BVariantA(),
        VariantB: BVariantB(),
        VariantC: BVariantC(),
      });

      // Serialize
      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      // Deserialize
      final reader = BinaryReader(bytes.buffer.asByteData());
      final deserialized = enumType.read(reader);

      expect(deserialized.discriminant, equals(1));
      expect(deserialized.variant.message, equals('hello'));
    });

    test('should serialize and deserialize VariantC', () {
      final original = ExampleEnum.variantC();

      final enumType = BEnum<ExampleEnum>({
        VariantA: BVariantA(),
        VariantB: BVariantB(),
        VariantC: BVariantC(),
      });

      // Serialize
      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      // Deserialize
      final reader = BinaryReader(bytes.buffer.asByteData());
      final deserialized = enumType.read(reader);

      expect(deserialized.discriminant, equals(2));
      expect(deserialized.variant, isA<VariantC>());
    });

    test('should handle named parameters in factory constructors', () {
      final enumType = BEnum<NamedEnum>({NamedVariant: BNamedVariant()});

      final original = NamedEnum.namedVariant(name: 'test', value: 123);

      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      final reader = BinaryReader(bytes.buffer.asByteData());
      final deserialized = enumType.read(reader);

      expect(deserialized.discriminant, equals(0));
      expect(deserialized.variant.name, equals('test'));
      expect(deserialized.variant.value, equals(123));
    });

    test(
      'should throw error when no matching field found for required parameter',
      () {
        final enumType = BEnum<IncompleteEnum>({
          IncompleteVariant: BIncompleteVariant(),
        });

        final original = IncompleteEnum.incompleteVariant('test', 'ignored');

        final writer = BinaryWriter();
        enumType.write(writer, original);
        final bytes = writer.toArray();

        final reader = BinaryReader(bytes.buffer.asByteData());

        expect(
          () => enumType.read(reader),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('No matching field found for required parameter'),
            ),
          ),
        );
      },
    );

    test('should throw error when no matching factory constructor found', () {
      final enumType = BEnum<OrphanEnum>({OrphanVariant: BOrphanVariant()});

      final original = OrphanEnum.somethingElse('test');

      final writer = BinaryWriter();
      enumType.write(writer, original);
      final bytes = writer.toArray();

      final reader = BinaryReader(bytes.buffer.asByteData());

      expect(
        () => enumType.read(reader),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No matching factory constructor found for variant'),
          ),
        ),
      );
    });
  });
}
