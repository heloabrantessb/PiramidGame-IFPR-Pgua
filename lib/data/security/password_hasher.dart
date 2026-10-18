import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class PasswordDigest {
  final String hash;
  final String salt;
  final int iterations;
  const PasswordDigest(this.hash, this.salt, this.iterations);
}

class PasswordHasher {
  final int iterations;
  const PasswordHasher({this.iterations = 600000});

  Future<PasswordDigest> hash(String password) async {
    final random = Random.secure();
    final salt = base64Encode(List.generate(32, (_) => random.nextInt(256)));
    final digest = await Isolate.run(() => derive(password, salt, iterations));
    return PasswordDigest(digest, salt, iterations);
  }

  Future<bool> verify(String password, PasswordDigest stored) async {
    final actual = await Isolate.run(
      () => derive(password, stored.salt, stored.iterations),
    );
    final a = base64Decode(actual);
    final b = base64Decode(stored.hash);
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  // PBKDF2-HMAC-SHA256, uma chave de 32 bytes; senha nunca é persistida.
  static String derive(String password, String salt, int iterations) {
    if (iterations < 1) throw ArgumentError.value(iterations);
    final hmac = Hmac(sha256, utf8.encode(password));
    var block = hmac.convert([...base64Decode(salt), 0, 0, 0, 1]).bytes;
    final output = Uint8List.fromList(block);
    for (var round = 1; round < iterations; round++) {
      block = hmac.convert(block).bytes;
      for (var i = 0; i < output.length; i++) {
        output[i] ^= block[i];
      }
    }
    return base64Encode(output);
  }
}
