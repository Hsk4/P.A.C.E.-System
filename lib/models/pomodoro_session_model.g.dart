// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_model.dart';

class PomodoroSessionModelAdapter extends TypeAdapter<PomodoroSessionModel> {
  @override
  final int typeId = 2;

  @override
  PomodoroSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSessionModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      completedPomodoros: fields[2] as int,
      totalFocusMinutes: fields[3] as int,
      taskId: fields[4] as String?,
      taskTitle: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSessionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.completedPomodoros)
      ..writeByte(3)
      ..write(obj.totalFocusMinutes)
      ..writeByte(4)
      ..write(obj.taskId)
      ..writeByte(5)
      ..write(obj.taskTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
