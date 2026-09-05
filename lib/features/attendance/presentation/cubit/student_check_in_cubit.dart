import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'student_check_in_state.dart';

class StudentCheckInCubit extends Cubit<StudentCheckInState> {
  final AttendanceRepository repository;

  StudentCheckInCubit({required this.repository})
      : super(const StudentCheckInInitial());

  Future<void> submitCheckIn({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    required CheckInMethod method,
    required String pinOrToken,
  }) async {
    final trimmed = pinOrToken.trim();
    if (trimmed.isEmpty) {
      emit(const StudentCheckInFailure('Please provide a valid QR code scan or 6-digit PIN.'));
      return;
    }

    emit(const StudentCheckInSubmitting());
    try {
      final record = await repository.checkInStudent(
        sessionId: sessionId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        studentAvatar: studentAvatar,
        method: method,
        pinOrToken: trimmed,
      );

      final statusMsg = record.status == AttendanceStatus.late
          ? 'Check-in recorded (marked as Late due to arrival time).'
          : 'Attendance confirmed! You are marked as Present.';

      emit(StudentCheckInSuccess(record: record, message: statusMsg));
    } catch (e) {
      emit(StudentCheckInFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(const StudentCheckInInitial());
  }
}
