import 'dart:mirrors';

import 'package:borsh_annotation_extended/borsh_annotation_extended.dart';

class BEnum<T> extends BType<T> {
  const BEnum(this.variants);

  final Map<Type, BType> variants;

  List<Type> get _variantTypes => variants.keys.toList();

  @override
  void write(BinaryWriter writer, T value) {
    final instanceMirror = reflect(value);
    final toBorshMethod = instanceMirror.invoke(Symbol('toBorsh'), []);
    final bytes = toBorshMethod.reflectee as Uint8List;

    writer.writeStruct(bytes);
  }

  @override
  T read(BinaryReader reader) {
    final discriminant = reader.readU8();

    if (discriminant < 0 || discriminant >= _variantTypes.length) {
      throw RangeError.range(
        discriminant,
        0,
        _variantTypes.length - 1,
        'discriminant',
        'Invalid enum discriminant',
      );
    }

    final variantType = _variantTypes[discriminant];
    final variantBType = variants[variantType]!;

    var variantResult = variantBType.read(reader);
    final enumClassMirror = reflectClass(T);

    for (var MapEntry(key: declarationKey, value: declarationValue)
        in enumClassMirror.declarations.entries) {
      if (_filterFactoryConstructor(
        declarationKey,
        declarationValue,
        variantResult.runtimeType,
      )) {
        final methodMirror = declarationValue as MethodMirror;

        final (positionalArgs, namedArgs) = _extractParams(
          methodMirror.parameters,
          variantResult,
        );
        return _createInstance(
          methodMirror,
          enumClassMirror,
          positionalArgs,
          namedArgs,
        );
      }
    }

    throw StateError(
      'No matching factory constructor found for variant ${variantResult.runtimeType}',
    );
  }

  bool _checkClassName(Symbol declarationKey, Type subClassType) {
    final className = subClassType.toString();

    final expectedValue = className.startsWith('_')
        ? className.substring(1).toLowerCase()
        : className.toLowerCase();

    final keyString = declarationKey.toString().toLowerCase();

    return keyString.contains(expectedValue);
  }

  bool _filterFactoryConstructor(
    Symbol declarationKey,
    DeclarationMirror declarationValue,
    Type subClassType,
  ) {
    return declarationValue is MethodMirror &&
        declarationValue.isConstructor &&
        declarationValue.isFactoryConstructor &&
        _checkClassName(declarationKey, subClassType);
  }

  T _createInstance(
    MethodMirror methodMirror,
    ClassMirror enumClassMirror,
    List<dynamic> positionalArgs,
    Map<Symbol, dynamic> namedArgs,
  ) {
    final fullConstructorName = MirrorSystem.getName(methodMirror.simpleName);
    final constructorName = fullConstructorName.split('.').last;

    return enumClassMirror
        .newInstance(Symbol(constructorName), positionalArgs, namedArgs)
        .reflectee;
  }

  (List<dynamic>, Map<Symbol, dynamic>) _extractParams(
    List<ParameterMirror> parameters,
    dynamic variantResult,
  ) {
    final variantMirror = reflect(variantResult);
    final variantInstanceMirror = variantMirror.type;

    final fieldMap = <String, dynamic>{};
    for (var variantDecl in variantInstanceMirror.declarations.values) {
      if (variantDecl is VariableMirror ||
          (variantDecl is MethodMirror && variantDecl.isGetter)) {
        final fieldName = MirrorSystem.getName(variantDecl.simpleName);
        try {
          final fieldValue = variantMirror
              .getField(Symbol(fieldName))
              .reflectee;
          fieldMap[fieldName] = fieldValue;
        } catch (e) {
          throw StateError(
            'Failed to access field "$fieldName" in variant ${variantResult.runtimeType}: $e',
          );
        }
      }
    }

    List<dynamic> positionalArgs = [];
    Map<Symbol, dynamic> namedArgs = {};

    for (var param in parameters) {
      final paramName = MirrorSystem.getName(param.simpleName);
      final fieldValue = fieldMap[paramName];

      if (fieldValue == null && !param.hasDefaultValue) {
        throw ArgumentError.value(
          paramName,
          'parameter',
          'No matching field found for required parameter in variant ${variantResult.runtimeType}. Available fields: ${fieldMap.keys.join(', ')}',
        );
      }

      if (param.isNamed) {
        namedArgs[Symbol(paramName)] = fieldValue;
      } else {
        positionalArgs.add(fieldValue);
      }
    }
    return (positionalArgs, namedArgs);
  }
}
