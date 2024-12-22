import 'package:reqwest/reqwest.dart';
import 'package:test/test.dart';

void main() {
  test('Get request', () {
      final client = Client();
      client.post("https://www.rust-lang.org");
    });
}
