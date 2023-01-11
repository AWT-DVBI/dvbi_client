// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String _$getDVBIHash() => r'93afe7ae5128bebfafca764199e942666a6ace45';

/// See also [getDVBI].
final getDVBIProvider = AutoDisposeFutureProvider<DVBI>(
  getDVBI,
  name: r'getDVBIProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getDVBIHash,
);
typedef GetDVBIRef = AutoDisposeFutureProviderRef<DVBI>;
String _$streamServiceElemsHash() =>
    r'86073b1836f76823fcefcebeb9e8b96a92ba0dbc';

/// See also [streamServiceElems].
final streamServiceElemsProvider = AutoDisposeProvider<Stream<ServiceElem>>(
  streamServiceElems,
  name: r'streamServiceElemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streamServiceElemsHash,
);
typedef StreamServiceElemsRef = AutoDisposeProviderRef<Stream<ServiceElem>>;
String _$serviceListHash() => r'31eaaad3d82e5a8d1249ec7926197913b5711cd0';

/// See also [serviceList].
final serviceListProvider = AutoDisposeProvider<Stream<List<ServiceElem>>>(
  serviceList,
  name: r'serviceListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$serviceListHash,
);
typedef ServiceListRef = AutoDisposeProviderRef<Stream<List<ServiceElem>>>;
