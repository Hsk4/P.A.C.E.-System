// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 1;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as String,
      label: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      isEnabled: fields[4] as bool,
      repeatDays: (fields[5] as List).cast<bool>(),
      customRingtonePath: fields[6] as String?,
      ringtoneName: fields[7] as String,
      notificationId: fields[8] as int,
      volume: fields[9] as int,
      vibrate: fields[10] as bool,
      lastTriggered: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.repeatDays)
      ..writeByte(6)
      ..write(obj.customRingtonePath)
      ..writeByte(7)
      ..write(obj.ringtoneName)
      ..writeByte(8)
      ..write(obj.notificationId)
      ..writeByte(9)
      ..write(obj.volume)
      ..writeByte(10)
      ..write(obj.vibrate)
      ..writeByte(11)
      ..write(obj.lastTriggered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
