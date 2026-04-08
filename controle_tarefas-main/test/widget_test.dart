import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tarefas/main.dart';

void main() {
  testWidgets('Adicionar tarefa na lista', (WidgetTester tester) async {
    // Constrói o app
    await tester.pumpWidget(const TaskApp());

    // Verifica que inicialmente não há nenhuma tarefa
    expect(find.byType(ListTile), findsNothing);

    // Toca no botão de adicionar
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // espera abrir o formulário

    // Preenche os campos do formulário
    await tester.enterText(find.byType(TextField).at(0), 'Estudar Flutter');
    await tester.enterText(find.byType(TextField).at(1), 'Ler capítulo sobre Widgets');

    // Confirma a criação da tarefa
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle(); // espera voltar para a lista

    // Verifica que a tarefa aparece na lista
    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Ler capítulo sobre Widgets'), findsOneWidget);
  });
}
