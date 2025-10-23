import 'package:borsh_annotation_extended/borsh_annotation_extended.dart';

part 'data.g.dart';

@BorshSerializable()
class Test1 with _$Test1 {
  factory Test1({
    @BString() required String stringValue,
    @BU8() required int intValue,
    @BU64() required BigInt bigIntValue,
    @BFixedArray(3, BString()) required List<String> listOfStrings,
    @BFixedArray(3, BU8()) required List<int> listOfInts,
    @BFixedArray(3, BFixedArray(2, BU8()))
    required List<List<int>> listOfListsOfInts,
    @BArray(BString()) required List<String> dynamicListOfStrings,
  }) = _Test1;

  const Test1._();

  factory Test1.fromBorsh(Uint8List data) => _$Test1FromBorsh(data);
}

@BorshSerializable()
class SimpleStruct with _$SimpleStruct {
  factory SimpleStruct({
    @BString() required String stringValue,
    @BU8() required int intValue,
  }) = _SimpleStruct;

  const SimpleStruct._();

  factory SimpleStruct.fromBorsh(Uint8List data) =>
      _$SimpleStructFromBorsh(data);
}

@BorshSerializable()
class CompositeStruct with _$CompositeStruct {
  factory CompositeStruct({
    @BU8() required int intValue,
    @BSimpleStruct() required SimpleStruct simpleStruct,
  }) = _CompositeStruct;

  const CompositeStruct._();

  factory CompositeStruct.fromBorsh(Uint8List data) =>
      _$CompositeStructFromBorsh(data);
}

@BorshSerializable()
class StructWithOption with _$StructWithOption {
  factory StructWithOption({
    @BString() required String stringValue,
    @BOption(BString()) required String? option,
  }) = _StructWithOption;

  const StructWithOption._();

  factory StructWithOption.fromBorsh(Uint8List data) =>
      _$StructWithOptionFromBorsh(data);
}

@BorshSerializable()
class StructWithNewTypes with _$StructWithNewTypes {
  factory StructWithNewTypes({
    @BU128() required BigInt u128Value,
    @BF32() required double f32Value,
    @BF64() required double f64Value,
    @BBytes() required Uint8List bytesValue,
    @BFixedBytes(32) required Uint8List fixedBytesValue,
  }) = _StructWithNewTypes;

  const StructWithNewTypes._();

  factory StructWithNewTypes.fromBorsh(Uint8List data) =>
      _$StructWithNewTypesFromBorsh(data);
}

@BorshSerializable()
class StructWithSignedTypes with _$StructWithSignedTypes {
  factory StructWithSignedTypes({
    @BI128() required BigInt i128Value,
    @BI64() required BigInt i64Value,
    @BI32() required int i32Value,
    @BI16() required int i16Value,
    @BI8() required int i8Value,
  }) = _StructWithSignedTypes;

  const StructWithSignedTypes._();

  factory StructWithSignedTypes.fromBorsh(Uint8List data) =>
      _$StructWithSignedTypesFromBorsh(data);
}

// Simple enum classes for testing - these will be used with reflection
class VariantA {
  const VariantA(this.value);
  final String value;

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(0); // discriminant
    BString().write(writer, value);
    return writer.toArray();
  }

  static VariantA fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final discriminant = reader.readU8();
    if (discriminant != 0) throw ArgumentError('Invalid discriminant');
    final value = BString().read(reader);
    return VariantA(value);
  }
}

class VariantB {
  const VariantB(this.value);
  final int value;

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(1); // discriminant
    BU32().write(writer, value);
    return writer.toArray();
  }

  static VariantB fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final discriminant = reader.readU8();
    if (discriminant != 1) throw ArgumentError('Invalid discriminant');
    final value = BU32().read(reader);
    return VariantB(value);
  }
}

class VariantC {
  const VariantC();

  Uint8List toBorsh() {
    final writer = BinaryWriter();
    writer.writeU8(2); // discriminant
    return writer.toArray();
  }

  static VariantC fromBorsh(Uint8List data) {
    final reader = BinaryReader(data.buffer.asByteData());
    final discriminant = reader.readU8();
    if (discriminant != 2) throw ArgumentError('Invalid discriminant');
    return VariantC();
  }
}

// Enum class for factory constructors
abstract class MyEnum {
  const MyEnum();

  factory MyEnum.variantA(VariantA variant) = _MyEnumVariantA;
  factory MyEnum.variantB(VariantB variant) = _MyEnumVariantB;
  factory MyEnum.variantC(VariantC variant) = _MyEnumVariantC;
}

class _MyEnumVariantA extends MyEnum {
  const _MyEnumVariantA(this.variant);
  final VariantA variant;
}

class _MyEnumVariantB extends MyEnum {
  const _MyEnumVariantB(this.variant);
  final VariantB variant;
}

class _MyEnumVariantC extends MyEnum {
  const _MyEnumVariantC(this.variant);
  final VariantC variant;
}

// Custom BType for VariantA that extracts the value field
class BVariantAType extends BType<VariantA> {
  const BVariantAType();

  @override
  void write(BinaryWriter writer, VariantA value) {
    BString().write(writer, value.value);
  }

  @override
  VariantA read(BinaryReader reader) {
    final data = BString().read(reader);
    return VariantA(data);
  }
}

// Custom BType for VariantB that extracts the value field
class BVariantBType extends BType<VariantB> {
  const BVariantBType();

  @override
  void write(BinaryWriter writer, VariantB value) {
    BU32().write(writer, value.value);
  }

  @override
  VariantB read(BinaryReader reader) {
    final data = BU32().read(reader);
    return VariantB(data);
  }
}

// Custom BType for VariantC (unit variant)
class BVariantCType extends BType<VariantC> {
  const BVariantCType();

  @override
  void write(BinaryWriter writer, VariantC value) {
    // Unit variant has no data to write
  }

  @override
  VariantC read(BinaryReader reader) {
    return VariantC();
  }
}

@BorshSerializable()
class StructWithEnum with _$StructWithEnum {
  factory StructWithEnum({
    @BString() required String name,
    @BEnum({
      VariantA: BVariantAType(),
      VariantB: BVariantBType(),
      VariantC: BVariantCType(),
    })
    required MyEnum enumValue,
  }) = _StructWithEnum;

  const StructWithEnum._();

  factory StructWithEnum.fromBorsh(Uint8List data) =>
      _$StructWithEnumFromBorsh(data);
}
