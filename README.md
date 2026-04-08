# FixBot - Industrial Equipment Troubleshooting App

A Flutter app built from Figma design (UuqXvQj2ccsEkzHXo2rru7).

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Welcome screen with gradient background & FixBot robot mascot |
| Onboarding | `/onboarding` | Robot + speech bubble intro, "Continue" button |
| Equipment Selection | `/equipment` | 2-column grid: Motor, Actuator, PLC, Sensor, Variator |
| Brand Selection | (modal) | Bottom sheet popup: Siemens, ABB, Schneider Electric, Mitsubishi |
| Model Selection | (modal) | Popup list of models for selected brand |
| Troubleshooting | `/troubleshooting` | Issue list with High/Medium/Low priority icons |
| Chat | `/chat` | FixBot AI chat with typing indicator & action buttons |

## Tech Stack

- **State management**: Riverpod (`flutter_riverpod`)
- **Navigation**: GoRouter (`go_router`)
- **Design system**: Custom theme matching Figma colors & typography

## Color Palette

| Name | Hex |
|------|-----|
| Primary Blue | `#2B547A` |
| Secondary Blue | `#436286` |
| Dark Accent | `#002C4B` |
| Gradient Start | `#436286` |
| Gradient End | `#002C4B` |
| High Priority | `#FB3434` |
| Medium Priority | `#C56100` |
| Low Priority | `#0E9D25` |

## Setup

```bash
cd fixbot
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry + GoRouter config
├── theme/
│   └── app_theme.dart     # Colors + ThemeData
├── providers/
│   └── diagnosis_provider.dart  # Riverpod state + data
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── equipment_selection_screen.dart
│   ├── troubleshooting_screen.dart
│   └── chat_screen.dart
└── widgets/
    ├── robot_avatar.dart   # Custom drawn FixBot mascot
    └── equipment_card.dart # Grid card widget
```
