import 'package:dio/dio.dart';
import 'api_client.dart';

class ExamService {
  final ApiClient _client;

  ExamService(this._client);

  Future<List<dynamic>> getPapers(int subjectId, {String? paperType}) async {
    try {
      final params = <String, dynamic>{'subjectId': subjectId};
      if (paperType != null) params['paperType'] = paperType;
      final res = await _client.get('/exam/papers', params: params);
      return _unwrapList(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPaperDetail(int paperId) async {
    try {
      final res = await _client.get('/exam/papers/$paperId');
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> startExam(int paperId) async {
    try {
      final res = await _client.post('/exam/start/$paperId');
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitExam({
    required int examRecordId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final res = await _client.post('/exam/submit', data: {
        'examRecordId': examRecordId,
        'answers': answers,
      });
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getExamHistory() async {
    try {
      final res = await _client.get('/exam/history');
      return _unwrapList(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> generateAdaptivePractice(int subjectId, {int count = 20}) async {
    try {
      final res = await _client.post('/exam/adaptive-practice',
          queryParameters: {'subjectId': subjectId, 'count': count});
      return _unwrap(res) as int;
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
