import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas/main.dart';
import 'package:tarefas/repository/configuracao_persistencia.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConfiguracaoPersistencia.carregar();
  });

  testWidgets('Adicionar tarefa na lista', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());

    await tester.tap(find.text('Minhas Tarefas'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Estudar Flutter');
    await tester.enterText(
      find.byType(TextField).at(1),
      'Ler capítulo sobre Widgets',
    );

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Ler capítulo sobre Widgets'), findsOneWidget);
  });
}
