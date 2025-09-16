
part of 'recurring_expense.dart';

class RecurringExpenseAdapter extends TypeAdapter<RecurringExpense> {
  @override
  final int typeId = 3;

  @override
  RecurringExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringExpense(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      amount: fields[2] as double,
      payee: fields[3] as String,
      notes: fields[4] as String?,
      frequency: fields[5] as String,
      nextDueDate: fields[6] as DateTime,
      isActive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringExpense obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.payee)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.nextDueDate)
      ..writeByte(7)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
