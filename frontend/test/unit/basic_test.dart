import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    test('Basic math test', () {
      expect(1 + 1, equals(2));
      expect(2 * 3, equals(6));
      expect(10 - 5, equals(5));
    });

    test('Basic string test', () {
      expect('hello', equals('hello'));
      expect('hello'.length, equals(5));
      expect('world', isIn('hello world'));
    });

    test('Basic list test', () {
      final list = [1, 2, 3];
      expect(list.length, equals(3));
      expect(list, contains(2));
      expect(list[0], equals(1));
    });

    test('Basic map test', () {
      final map = {'key': 'value', 'number': 42};
      expect(map.containsKey('key'), isTrue);
      expect(map['key'], equals('value'));
      expect(map['number'], equals(42));
    });

    test('Basic boolean test', () {
      expect(true, isTrue);
      expect(false, isFalse);
      expect(true, isNot(false));
    });
  });
}
