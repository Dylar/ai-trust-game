import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('treats accepted responses as success by default', () {
    expect(
      () => ensureSuccessResponse(http.Response('', 202)),
      returnsNormally,
    );
  });

  test('throws api exception for non-success responses', () {
    expect(
      () => ensureSuccessResponse(http.Response('', 400)),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          400,
        ),
      ),
    );
  });
}
