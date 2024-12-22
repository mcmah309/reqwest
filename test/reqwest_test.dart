import 'package:reqwest/reqwest.dart';
import 'package:test/test.dart';

void main() {
  test('Get request', () async {
    final client = Client();
    final result = await client.get("https://www.rust-lang.org").send();
    final text = await result.unwrap().text();
    final x = 1;
  });
}
