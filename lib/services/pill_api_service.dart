import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pill_summary.dart';
import '../models/pill_create_request.dart';
import '../models/medicine_response.dart';
import '../models/pill_detail.dart';
import '../models/today_pill.dart';
import 'package:intl/intl.dart';


class PillApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api';

  Future<List<PillSummary>> fetchPillSummaries() async {
    final response = await http.get(Uri.parse('$baseUrl/medicines/main'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PillSummary.fromJson(json)).toList();
    } else {
      throw Exception('약 목록 불러오기 실패');
    }
  }

  Future<void> addPill(PillCreateRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medicines'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('약 등록 실패');
    }
  }

  Future<List<MedicineResponse>> searchPills(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medicines/external/search?query=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => MedicineResponse.fromJson(json)).toList();
    } else {
      throw Exception('약 검색 실패');
    }
  }

  Future<PillDetail> fetchPillDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/medicines/$id/details'));

    if (response.statusCode == 200) {
      return PillDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('약 상세 정보 불러오기 실패');
    }
  }

  Future<void> updatePill(int id, PillCreateRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('약 수정 실패');
    }
  }

  Future<List<DateTime>> fetchTakenDates(int pillId) async {
  final response = await http.get(Uri.parse('$baseUrl/medicines/$pillId/dose-history'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => DateTime.parse(e)).toList();
    } else {
      throw Exception('복용 기록 불러오기 실패');
    }
  }

  Future<void> markPillAsTaken(int pillId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medicines/$pillId/take'),
    );
    if (response.statusCode != 200) {
      throw Exception('복용 기록 저장 실패');
    }
  }

  Future<List<TodayPill>> fetchTodayPills() async {
    final response = await http.get(Uri.parse('$baseUrl/medicines/today'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => TodayPill.fromJson(e)).toList();
    } else {
      throw Exception('오늘 복용할 약 불러오기 실패');
    }
  }

  Future<bool> checkTodayTaken(int pillId) async {
    final response = await http.get(Uri.parse('$baseUrl/doses/$pillId/today'));
    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return jsonMap['taken'] as bool;
    } else {
      throw Exception('오늘 복용 여부 확인 실패');
    }
  }
  Future<void> markAsTaken(int pillId) async {
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.post(
      Uri.parse('$baseUrl/doses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'pillId': pillId, 'doseDate': now}),
    );
    if (response.statusCode != 200) {
      throw Exception('복용 기록 실패');
    }
  }

  Future<void> deletePill(int pillId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/medicines/$pillId'),
    );

    if (response.statusCode != 204) {
      throw Exception('약 삭제 실패');
    }
  }
}

