import 'package:flutter/material.dart';

typedef Answered = void Function(bool correct);

class MultipleChoiceQuestion extends StatefulWidget {
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final Answered onAnswered;
  const MultipleChoiceQuestion({
    super.key, required this.prompt, required this.choices,
    required this.correctIndex, required this.onAnswered,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  int? selected;
  bool? wasCorrect;

  @override
  Widget build(BuildContext context) {
    final feedbackIcon = wasCorrect == null
        ? const SizedBox.shrink()
        : Icon(wasCorrect! ? Icons.check_circle : Icons.cancel,
        key: ValueKey(wasCorrect),
        color: wasCorrect! ? Colors.green : Colors.red, size: 26);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...List.generate(widget.choices.length, (i) {
          final choice = widget.choices[i];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: RadioListTile<int>(
                value: i,
                groupValue: selected,
                title: Text(choice),
                onChanged: (v) => setState(()=> selected = v),
              ),
            ),
          );
        }),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: selected == null ? null : () {
                  final ok = selected == widget.correctIndex;
                  setState(()=> wasCorrect = ok);
                  Future.delayed(const Duration(milliseconds: 300),
                          () => widget.onAnswered(ok));
                },
                child: const Text('Responder'),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: feedbackIcon),
          ],
        ),
      ],
    );
  }
}

class DragMatchQuestion extends StatefulWidget {
  final String prompt;
  final List<Map<String,String>> pairs;
  final Answered onAnswered;
  const DragMatchQuestion({super.key, required this.prompt, required this.pairs, required this.onAnswered});

  @override
  State<DragMatchQuestion> createState() => _DragMatchQuestionState();
}

class _DragMatchQuestionState extends State<DragMatchQuestion> {
  late List<String> left;
  late List<String> right;
  final Map<String,String> matched = {};

  @override
  void initState() {
    super.initState();
    left  = widget.pairs.map((e) => e['left']!).toList();
    right = widget.pairs.map((e) => e['right']!).toList()..shuffle();
  }

  bool get isComplete => matched.length == left.length;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      Expanded(
        child: Row(
          children: [
            Expanded(child: Column(children: left.map(_draggableChip).toList())),
            const SizedBox(width: 16),
            Expanded(child: Column(children: right.map(_dropTarget).toList())),
          ],
        ),
      ),
      ElevatedButton(
        onPressed: isComplete ? () {
          final allCorrect = widget.pairs.every((p) => matched[p['left']] == p['right']);
          widget.onAnswered(allCorrect);
        } : null,
        child: const Text('Comprobar'),
      ),
    ]);
  }

  Widget _draggableChip(String text) {
    final already = matched.containsKey(text);
    final chip = Chip(label: Text(text));
    return Opacity(
      opacity: already ? 0.35 : 1,
      child: Draggable<String>(
        data: text,
        feedback: Material(color: Colors.transparent, child: chip),
        childWhenDragging: chip,
        maxSimultaneousDrags: already ? 0 : 1,
        child: Container(margin: const EdgeInsets.symmetric(vertical: 6), child: chip),
      ),
    );
  }

  Widget _dropTarget(String targetRight) {
    final leftAssigned = matched.entries
        .firstWhere((e) => e.value == targetRight, orElse: () => const MapEntry('', ''))
        .key;

    return DragTarget<String>(
      builder: (_, candidate, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: candidate.isEmpty ? const Color(0xFFE0E0E0) : Colors.amber),
          ),
          child: Row(
            children: [
              Expanded(child: Text(targetRight)),
              if (leftAssigned.isNotEmpty) Chip(label: Text(leftAssigned)),
            ],
          ),
        );
      },
      onAccept: (leftItem) => setState(()=> matched[leftItem] = targetRight),
    );
  }
}

class OrderListQuestion extends StatefulWidget {
  final String prompt;
  final List<String> items;
  final Answered onAnswered;
  const OrderListQuestion({super.key, required this.prompt, required this.items, required this.onAnswered});

  @override
  State<OrderListQuestion> createState() => _OrderListQuestionState();
}

class _OrderListQuestionState extends State<OrderListQuestion> {
  late List<String> current;

  @override
  void initState() {
    super.initState();
    current = [...widget.items]..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      Expanded(
        child: ReorderableListView(
          children: [
            for (final item in current)
              Card(
                key: ValueKey(item),
                child: ListTile(
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
          ],
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = current.removeAt(oldIndex);
              current.insert(newIndex, item);
            });
          },
        ),
      ),
      ElevatedButton(
        onPressed: () => widget.onAnswered(_isCorrect()),
        child: const Text('Comprobar'),
      ),
    ]);
  }

  bool _isCorrect() {
    if (current.length != widget.items.length) return false;
    for (int i = 0; i < current.length; i++) {
      if (current[i] != widget.items[i]) return false;
    }
    return true;
  }
}
