import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class IconAdapter extends TypeAdapter<IconData> {
  @override
  final typeId = 2;

  @override
  IconData read(BinaryReader reader) {
    return IconData(reader.readInt(), fontFamily: 'MaterialIcons');
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    writer.writeInt(obj.codePoint);
  }
}