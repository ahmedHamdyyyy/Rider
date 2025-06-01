import 'dart:convert';
import 'dart:io';

// Replace with your actual API base URL
const String mBaseUrl = 'YOUR_API_BASE_URL';

// Replace with your authentication token
const String authToken = 'YOUR_AUTH_TOKEN';

// Replace these values with your actual test data
final Map<String, dynamic> testRideRequest = {
  "rider_id": 123, // Replace with an actual rider ID
  "service_id": 1, // Replace with an actual service ID
  "start_address": "Test Start Address",
  "start_latitude": 37.7749,
  "start_longitude": -122.4194,
  "end_address": "Test End Address",
  "end_latitude": 37.7749,
  "end_longitude": -122.4194,
  "distance": 5.0,
  "duration": 15,
  "payment_type": "cash",
  "is_schedule": 0,
  "tip_amount": 0
};

void main() async {
  print("Testing Book Ride API Endpoint");
  print("---------------------------------");

  try {
    final result = await testBookRideRequest();
    print("API Response:");
    print(json.encode(result));
    print("---------------------------------");
    print("Test completed successfully!");
  } catch (e) {
    print("Error occurred: $e");
  }
}

Future<dynamic> testBookRideRequest() async {
  final url = Uri.parse('$mBaseUrl/save-riderequest');

  print("Sending request to: $url");
  print("Request body:");
  print(json.encode(testRideRequest));

  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.authorizationHeader: 'Bearer $authToken',
    HttpHeaders.userAgentHeader: 'MightyTaxiRiderApp',
  };

  final response =
      await HttpClient().postUrl(url).then((HttpClientRequest request) {
    request.headers
        .set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
    request.headers.set(HttpHeaders.userAgentHeader, 'MightyTaxiRiderApp');
    request.write(json.encode(testRideRequest));
    return request.close();
  }).then((HttpClientResponse response) async {
    final stringData = await response.transform(utf8.decoder).join();
    print("Response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      return json.decode(stringData);
    } else {
      throw "API Error: ${response.statusCode}\nResponse: $stringData";
    }
  });

  return response;
}
