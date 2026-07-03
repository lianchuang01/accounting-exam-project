import 'package:dio/dio.dart';
import 'api_client.dart';

class ReportService {
  final ApiClient _client;

  ReportService(this._client);

  Future<Map<String, dynamic>> getReport() async {
    try {
      final res = await _client.get('/report/overview');
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getKnowledgeMastery() async {
    try {
      final res = await _client.get('/report/knowledge-mastery');
      return _unwrapList(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getWrongQuestions({bool? isCleared}) async {
    try {
      final params = <String, dynamic>{};
      if (isCleared != null) params['isCleared'] = isCleared;
      final res = await _client.get('/wrong-book/list', params: params);
      return _unwrapList(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getVoiceQueue({List<int>? questionIds}) async {
    try {
      final params = <String, dynamic>{};
      if (questionIds != null && questionIds.isNotEmpty) {
        params['questionIds'] = questionIds.join(',');
      }
      final res = await _client.get('/wrong-book/voice-queue', params: params);
      return _unwrapList(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> clearWrongQuestion(int questionId) async {
    try {
      await _client.put('/wrong-book/clear/$questionId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _unwrap(Response res) {
    final data = res.data as Map<String, dynamic>;
    if (data['code'] != 200) throw Exception(data['message'] ?? '请求失败');
    return data['data'] as Map<String, dynamic>;
  }

  List<dynamic> _unwrapList(Response res) {
    final data = res.data as Map<String, dynamic>;
    if (data['code'] != 200) throw Exception(data['message'] ?? '请求失败');
    return data['data'] as List<dynamic>;
  }

  Exception _handleError(DioException e) {
    if (e.response?.data != null) {
      final msg = (e.response!.data as Map)['message'] ?? '网络错误';
      return Exception(msg.toString());
    }
    return Exception('网络连接失败');
  }
}
