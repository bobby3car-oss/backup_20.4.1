import '../domain/appointment.dart';

abstract class AppointmentsRepository {
  Stream<List<Appointment>> watchAll();
  Stream<List<Appointment>> watchRange(DateTime from, DateTime to);
  Future<void> upsert(Appointment appointment);
  Future<void> delete(String id);
  Future<Appointment?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
  Future<void> switchUser(String? userId);
}
