import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'logout_response.g.dart';

@JsonSerializable(createToJson: false)
class LogoutResponse extends Equatable {
  final bool success;
  final String message;

  const LogoutResponse({this.success = false, this.message = ''});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseFromJson(json);

  @override
  List<Object?> get props => [success, message];
}
