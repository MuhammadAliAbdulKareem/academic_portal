import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class StudentCheckInState extends Equatable {
  const StudentCheckInState();

  @override
  List<Object?> get props => [];
}

class StudentCheckInInitial extends StudentCheckInState {
  const StudentCheckInInitial();
}

class StudentCheckInSubmitting extends StudentCheckInState {
  const StudentCheckInSubmitting();
}

class StudentCheckInSuccess extends StudentCheckInState {
  final AttendanceRecordEntity record;
  final String message;

  const StudentCheckInSuccess({
    required this.record,
    this.message = 'Check-in verified successfully!',
  });

  @override
  List<Object?> get props => [record, message];
}

class StudentCheckInFailure extends StudentCheckInState {
  final String errorMessage;

  const StudentCheckInFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
