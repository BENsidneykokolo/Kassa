import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

enum AttendanceStatus { present, absent, enPause, enConge }

class Employee extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String position;
  final String department;
  final StaffRole role;
  final DateTime hireDate;
  final AttendanceStatus attendanceStatus;
  final String? photoUrl;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.position,
    required this.department,
    required this.role,
    required this.hireDate,
    this.attendanceStatus = AttendanceStatus.absent,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, role];
}
