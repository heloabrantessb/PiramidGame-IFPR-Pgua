import 'package:signals_flutter/signals_flutter.dart';
import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/entity/student_entity.dart';
import '../commands/student_commands.dart';
import 'student_state_viewmodel.dart';

class StudentCommandsViewModel {
  final StudentStateViewModel state;

  final GetAllStudentsCommand _getAllStudentsCommand;
  final GetStudentByIdCommand _getStudentByIdCommand;
  final AddStudentCommand _addStudentCommand;
  final UpdateStudentCommand _updateStudentCommand;
  final DeleteStudentCommand _deleteStudentCommand;

  StudentCommandsViewModel({
    required this.state,
    required GetAllStudentsCommand getAllStudentsCommand,
    required GetStudentByIdCommand getStudentByIdCommand,
    required AddStudentCommand addStudentCommand,
    required UpdateStudentCommand updateStudentCommand,
    required DeleteStudentCommand deleteStudentCommand,
  })  : _getAllStudentsCommand = getAllStudentsCommand,
        _getStudentByIdCommand = getStudentByIdCommand,
        _addStudentCommand = addStudentCommand,
        _updateStudentCommand = updateStudentCommand,
        _deleteStudentCommand = deleteStudentCommand {
    
    // Inicializa a observação das reações de cada comando
    _observeGetAllStudents();
    _observeGetStudentById();
    _observeAddStudent();
    _observeUpdateStudent();
    _observeDeleteStudent();
  }

  // ========================================================
  //   GETTERS PÚBLICOS DOS COMANDOS (PARA A UI CONECTAR DIRETAMENTE)
  // ========================================================
  GetAllStudentsCommand get getAllStudentsCommand => _getAllStudentsCommand;
  GetStudentByIdCommand get getStudentByIdCommand => _getStudentByIdCommand;
  AddStudentCommand get addStudentCommand => _addStudentCommand;
  UpdateStudentCommand get updateStudentCommand => _updateStudentCommand;
  DeleteStudentCommand get deleteStudentCommand => _deleteStudentCommand;

  // ========================================================
  //   MÉTODO UTILITÁRIO DE OBSERVAÇÃO
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      if (command.isExecuting.value) return;

      final result = command.result.value;
      if (result == null) return;

      result.fold(
        onSuccess: (data) {
          state.clearMessage();
          onSuccess(data);
          command.clear();
        },
        onFailure: (err) {
          state.setMessage(err.msg);
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS ESPECÍFICOS DOS COMANDOS
  // ========================================================
  void _observeGetAllStudents() {
    _observeCommand<List<Student>>(
      _getAllStudentsCommand,
      onSuccess: (list) {
        state.setStudents(list);
      },
    );
  }

  void _observeGetStudentById() {
    _observeCommand<Student>(
      _getStudentByIdCommand,
      onSuccess: (student) {
        state.setSelectedStudent(student);
      },
    );
  }

  void _observeAddStudent() {
    _observeCommand<void>(
      _addStudentCommand,
      onSuccess: (_) {
        state.setSuccessEvent(StudentSuccessEvent.created);
        state.clearMessage();
        fetchStudents(); // Recarrega a lista
      },
    );
  }

  void _observeUpdateStudent() {
    _observeCommand<void>(
      _updateStudentCommand,
      onSuccess: (_) {
        state.setSuccessEvent(StudentSuccessEvent.updated);
        state.clearMessage();
        fetchStudents(); // Recarrega a lista
      },
    );
  }

  void _observeDeleteStudent() {
    _observeCommand<void>(
      _deleteStudentCommand,
      onSuccess: (_) {
        state.setSuccessEvent(StudentSuccessEvent.deleted);
        state.clearMessage();
        state.setSelectedStudent(null);
        fetchStudents(); // Recarrega a lista
      },
    );
  }

  // ========================================================
  //   MÉTODOS PÚBLICOS DE DISPARO DAS AÇÕES (FACHADA PARA A VIEW)
  // ========================================================
  Future<void> fetchStudents() async {
    state.clearMessage();
    await _getAllStudentsCommand.call();
  }

  Future<void> fetchStudentById(String id) async {
    state.clearMessage();
    await _getStudentByIdCommand.executeWith(id);
  }

  Future<void> addStudent(Student student) async {
    state.clearMessage();
    await _addStudentCommand.executeWith(student);
  }

  Future<void> updateStudent(Student student) async {
    state.clearMessage();
    await _updateStudentCommand.executeWith(student);
  }

  Future<void> deleteStudent(String id) async {
    state.clearMessage();
    await _deleteStudentCommand.executeWith(id);
  }
}
