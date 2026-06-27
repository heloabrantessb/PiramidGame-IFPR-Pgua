import '../../core/patterns/i_usecase.dart';
import '../../core/patterns/result.dart';
import '../../core/failure/failure.dart';
import '../entity/student_entity.dart';

abstract interface class IGetAllStudentsUseCase 
    implements IUseCase<Result<List<Student>, Failure>, void> {}

abstract interface class IGetStudentByIdUseCase 
    implements IUseCase<Result<Student, Failure>, String> {}

abstract interface class IAddStudentUseCase 
    implements IUseCase<Result<void, Failure>, Student> {}

abstract interface class IUpdateStudentUseCase 
    implements IUseCase<Result<void, Failure>, Student> {}

abstract interface class IDeleteStudentUseCase 
    implements IUseCase<Result<void, Failure>, String> {}