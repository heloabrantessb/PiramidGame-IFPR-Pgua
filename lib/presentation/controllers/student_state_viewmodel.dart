import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/entity/student_entity.dart';

enum StudentSuccessEvent { created, updated, deleted }

class StudentStateViewModel {
  final students = signal<List<Student>>([]);
  final selectedStudent = signal<Student?>(null);
  final message = signal<String?>(null);
  final successEvent = signal<StudentSuccessEvent?>(null);

  late final isEditing = computed(() => selectedStudent.value != null);

  late final ranking = computed(() {
    final list = List<Student>.from(students.value);
    list.sort((a, b) => b.ratings.nivelLenda.compareTo(a.ratings.nivelLenda));
    return list;
  });

  void setStudents(List<Student> list) => students.value = list;

  void setSelectedStudent(Student? student) => selectedStudent.value = student;

  void setMessage(String? msg) => message.value = msg;

  void clearMessage() => message.value = null;

  void setSuccessEvent(StudentSuccessEvent event) => successEvent.value = event;

  void clearSuccessEvent() => successEvent.value = null;

  void reset() {
    selectedStudent.value = null;
    message.value = null;
    successEvent.value = null;
  }
}
