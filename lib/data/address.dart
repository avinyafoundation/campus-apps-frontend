import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class Address {
  String? record_type;
  int? id;
  String? name_en;
  String? street_address;
  int? phone;
  int? city_id;

  Address({
    this.id,
    this.name_en,
    this.street_address,
    this.phone,
    this.city_id,
    this.record_type,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name_en: json['name_en'],
      street_address: json['street_address'],
      phone: json['phone'],
      city_id: json['city_id'],
      record_type: json['record_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name_en != null) 'name_en': name_en,
        if (street_address != null) 'street_address': street_address,
        if (phone != null) 'phone': phone,
        if (city_id != null) 'city_id': city_id,
        if (record_type != null) 'record_type': record_type,
      };
}

Future<List<Address>> fetchAddresss() async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/address'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    log(resultsJson.toString());
    List<Address> addresss = await resultsJson
        .map<Address>((json) => Address.fromJson(json))
        .toList();
    return addresss;
  } else {
    throw Exception('Failed to load Address');
  }
}

Future<Address> fetchAddress(String id) async {
  final response = await http.get(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/address/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': 'application/json',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    Address address = Address.fromJson(json.decode(response.body));
    return address;
  } else {
    throw Exception('Failed to load Address');
  }
}

Future<Address> createAddress(Address address) async {
  final response = await http.post(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/address'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(address.toJson()),
  );

  if (response.statusCode == 200) {
    log(response.body);
    Address createdAddress = Address.fromJson(json.decode(response.body));
    return createdAddress;
  } else {
    log(response.body + " Status code =" + response.statusCode.toString());
    throw Exception('Failed to create Person.');
  }
}

Future<http.Response> updateAddress(Address address) async {
  final response = await http.put(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/address'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
    body: jsonEncode(address.toJson()),
  );
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to update Address.');
  }
}

Future<http.Response> deleteAddress(String id) async {
  final http.Response response = await http.delete(
    Uri.parse(AppConfig.campusAttendanceBffApiUrl + '/address/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + AppConfig.campusAttendanceBffApiKey,
    },
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to delete Address.');
  }
}
