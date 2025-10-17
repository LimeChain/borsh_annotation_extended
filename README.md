# Borsh Annotation Extended

An extended borsh_annotation library that adds support for additional data types and enhanced binary reading/writing capabilities.

## Features

This library extends the original `borsh_annotation` package with:

### Extended Data Types
- **BU128**: Support for 128-bit unsigned integers (`BigInt`)
- **BF32**: Support for 32-bit floating point numbers (`double`)
- **BF64**: Support for 64-bit floating point numbers (`double`)
- **BFixedArray**: Enhanced fixed-size array support with custom write methods

### Extended Binary Writers/Readers
- **ExtendedBinaryWriter**: Wraps standard `BinaryWriter` to add new methods
- **ExtendedBinaryReader**: Wraps standard `BinaryReader` to add new methods

## Usage

### Using Extended Types

```dart
import 'package:borsh_annotation_extended/borsh_annotation_extended.dart';

// 128-bit unsigned integer
@BU128()
BigInt myBigInt;

// 32-bit float
@BF32()
double myFloat32;

// 64-bit float  
@BF64()
double myFloat64;

// Fixed array with custom behavior
@BFixedArray(5, BU8())
List<int> myFixedArray;
```

### Extended Writers and Readers

The library automatically wraps standard `BinaryWriter` and `BinaryReader` instances to provide extended functionality:

```dart
// The extended types automatically use ExtendedBinaryWriter/Reader
ExtendedBinaryWriter writer = ExtendedBinaryWriter.fromBinaryWriter(standardWriter);
writer.writeU128(myBigInt);
writer.writeF32(myFloat);

ExtendedBinaryReader reader = ExtendedBinaryReader.fromBinaryReader(standardReader);
BigInt value = reader.readU128();
double floatValue = reader.readF32();
```

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  borsh_annotation_extended: ^0.0.1
```

## Dependencies

- `borsh_annotation: ^0.3.2`
- Dart SDK: `^3.9.2`

## Architecture

This library follows a wrapper pattern that:
1. Extends the base `BinaryWriter`/`BinaryReader` classes
2. Preserves the original writer/reader state 
3. Adds new methods for additional data types
4. Maintains compatibility with existing borsh_annotation code

Each extended type (`BU128`, `BF32`, etc.) automatically wraps the provided writer/reader to use the extended functionality while maintaining the original buffer state.