import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/expense.dart';

class ExcelService {
  Future<String> exportExpenses(List<Expense> expenses) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Expenses'];

    // Add headers using CellValue objects
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Category ID'),
      TextCellValue('Amount'),
      TextCellValue('Date'),
      TextCellValue('Payee'),
      TextCellValue('Notes')
    ]);

    // Add data using appropriate CellValue types
    for (var expense in expenses) {
      sheet.appendRow([
        TextCellValue(expense.id),
        TextCellValue(expense.categoryId),
        DoubleCellValue(expense.amount),
        TextCellValue(expense.date.toIso8601String()),
        TextCellValue(expense.payee),
        TextCellValue(expense.notes ?? '')
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'expenses_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  Future<List<Map<String, dynamic>>> importExpenses() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables[excel.tables.keys.first]!;

        final expenses = <Map<String, dynamic>>[];
        bool isHeader = true;

        for (var row in sheet.rows) {
          if (isHeader) {
            isHeader = false;
            continue;
          }

          if (row.length >= 6) {
            expenses.add({
              'id': row[0]?.value?.toString() ?? DateTime.now().toString(),
              'categoryId': row[1]?.value?.toString() ?? '',
              'amount': double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0,
              'date': DateTime.tryParse(row[3]?.value?.toString() ?? '') ?? DateTime.now(),
              'payee': row[4]?.value?.toString() ?? '',
              'notes': row[5]?.value?.toString()
            });
          }
        }

        return expenses;
      }
      return [];
    } catch (e) {
      print('Error importing Excel file: $e');
      return [];
    }
  }
}