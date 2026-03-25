import 'functions_client.dart';

class MessagesService {
  MessagesService(this._fn);

  final FunctionsClient _fn;

  Future<List<Map<String, dynamic>>> list({
    int limit = 40,
    int offset = 0,
  }) async {
    final data = await _fn.invoke(
      'list-messages',
      body: {'limit': limit, 'offset': offset},
    );
    final items = data['items'] as List? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
