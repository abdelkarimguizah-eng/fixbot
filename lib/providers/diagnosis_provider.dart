import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Models ---

class DiagnosisState {
  final String? selectedEquipment;
  final String? selectedBrand;
  final String? selectedModel;
  final String? selectedProblem;
  final List<ChatMessage> messages;

  const DiagnosisState({
    this.selectedEquipment,
    this.selectedBrand,
    this.selectedModel,
    this.selectedProblem,
    this.messages = const [],
  });

  DiagnosisState copyWith({
    String? selectedEquipment,
    String? selectedBrand,
    String? selectedModel,
    String? selectedProblem,
    List<ChatMessage>? messages,
  }) {
    return DiagnosisState(
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedProblem: selectedProblem ?? this.selectedProblem,
      messages: messages ?? this.messages,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class EquipmentBrand {
  final String name;
  final String initial;
  final List<String> models;

  const EquipmentBrand({
    required this.name,
    required this.initial,
    required this.models,
  });
}

class TroubleshootingIssue {
  final String title;
  final String priority; // 'high', 'medium', 'low'

  const TroubleshootingIssue({required this.title, required this.priority});
}

// --- Notifiers ---

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  DiagnosisNotifier() : super(const DiagnosisState());

  void selectEquipment(String equipment) =>
      state = state.copyWith(selectedEquipment: equipment);

  void selectBrand(String brand) =>
      state = state.copyWith(selectedBrand: brand);

  void selectModel(String model) =>
      state = state.copyWith(selectedModel: model);

  void selectProblem(String problem) =>
      state = state.copyWith(selectedProblem: problem);

  void addMessage(ChatMessage message) =>
      state = state.copyWith(messages: [...state.messages, message]);

  void reset() => state = const DiagnosisState();
}

// --- Providers ---

final diagnosisProvider =
    StateNotifierProvider<DiagnosisNotifier, DiagnosisState>(
      (ref) => DiagnosisNotifier(),
    );

// Equipment data
final equipmentListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'Motor', 'icon': 'motor'},
    {'name': 'Actuator', 'icon': 'actuator'},
    {'name': 'PLC', 'icon': 'plc'},
    {'name': 'Sensor', 'icon': 'sensor'},
    {'name': 'Variator', 'icon': 'variator'},
  ];
});

final brandsProvider = Provider<List<EquipmentBrand>>((ref) {
  return const [
    EquipmentBrand(
      name: 'Siemens',
      initial: 'S',
      models: ['1LA7 Motor', '1LA8 Motor', 'SIMOTICS GP'],
    ),
    EquipmentBrand(
      name: 'ABB',
      initial: 'A',
      models: ['M2AA Motor', 'M3AA Motor', 'IE3 Series'],
    ),
    EquipmentBrand(
      name: 'Schneider Electric',
      initial: 'SE',
      models: ['IMfinity', 'IMO Series', 'Dyneo+'],
    ),
    EquipmentBrand(
      name: 'Mitsubishi Electric',
      initial: 'M',
      models: ['SF-JR Series', 'SF-HR Series', 'GM-D Series'],
    ),
  ];
});

final troubleshootingIssuesProvider =
    Provider.family<List<TroubleshootingIssue>, String>((ref, equipment) {
      return [
        const TroubleshootingIssue(
          title: 'Overheating',
          priority: 'high',
        ),
        const TroubleshootingIssue(
          title: 'Excessive Vibration',
          priority: 'high',
        ),
        const TroubleshootingIssue(
          title: 'Abnormal Noise',
          priority: 'medium',
        ),
        const TroubleshootingIssue(
          title: 'Power Fluctuation',
          priority: 'medium',
        ),
        const TroubleshootingIssue(
          title: 'Startup Delay',
          priority: 'low',
        ),
      ];
    });
