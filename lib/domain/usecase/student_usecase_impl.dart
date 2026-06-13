class StudentUseCaseImpl implements StudentUseCaseInterface {
    final IStudentRepository _repository;

    StudentUseCaseImpl(this._repository);
   
    @override
    Future<Result<void, Failure>> createStudent(StudentEntity params) {
        return _repository.create(params);
    }

    @override
    Future<Result<void, Failure>> deleteStudent(String id) {
        return _repository.delete(id);
    }
    
    @override
    Future<Result<void, Failure>> updateStudent(StudentEntity params) {
        return _repository.update(params);
    }

    @override
    Future<Result<List<StudentEntity>, Failure>> getStudents() {
        return _repository.getAll();
    }

    @override
    Future<Result<StudentEntity, Failure>> getStudentById(String id) {
        return _repository.getById(id);
    }
}