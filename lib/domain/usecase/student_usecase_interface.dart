import '../entity/student_entity.dart';

abstract interface class IStudentUseCase {
  Future<ResultType<void>> createStudent();
  Future<ResultType<void>> deleteStudent();
  Future<ResultType<void>> updateStudent();
  Future<ResultType<List<StudentEntity>>> getStudents();
  Future<ResultType<StudentEntity>> getStudentById(String id);
}