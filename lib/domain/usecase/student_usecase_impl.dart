import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../entity/student_entity.dart';
import '../../data/repositories/student_repository_interface.dart';
import 'student_usecase_interface.dart';

final class GetAllStudentsUseCaseImpl implements IGetAllStudentsUseCase {
  final IStudentRepository _repository;

  GetAllStudentsUseCaseImpl(this._repository);

  @override
  Future<Result<List<Student>, Failure>> call(void params) async {
    return await _repository.getAll();
  }
}

final class GetStudentByIdUseCaseImpl implements IGetStudentByIdUseCase {
  final IStudentRepository _repository;

  GetStudentByIdUseCaseImpl(this._repository);

  @override
  Future<Result<Student, Failure>> call(String id) async {
    return await _repository.getById(id);
  }
}

final class AddStudentUseCaseImpl implements IAddStudentUseCase {
  final IStudentRepository _repository;

  AddStudentUseCaseImpl(this._repository);

  @override
  Future<Result<void, Failure>> call(Student student) async {
    return await _repository.create(student).then((result) => result.fold(
          onSuccess: (_) => const Success(null),
          onFailure: (failure) => Error(failure),
        ));
  }
}

final class UpdateStudentUseCaseImpl implements IUpdateStudentUseCase {
  final IStudentRepository _repository;

  UpdateStudentUseCaseImpl(this._repository);

  @override
  Future<Result<void, Failure>> call(Student student) async {
    return await _repository.update(student).then((result) => result.fold(
          onSuccess: (_) => const Success(null),
          onFailure: (failure) => Error(failure),
        ));
  }
}

final class DeleteStudentUseCaseImpl implements IDeleteStudentUseCase {
  final IStudentRepository _repository;

  DeleteStudentUseCaseImpl(this._repository);

  @override
  Future<Result<void, Failure>> call(String id) async {
    return await _repository.delete(id);
  }
}