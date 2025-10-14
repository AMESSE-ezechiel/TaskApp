# task_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Routes

Cette application expose une route nommée `/login` qui pointe vers le widget `LoginPage`.
Vous pouvez lancer l'application et naviguer vers cette route par :

- initialRoute dans `lib/main.dart` est défini sur `/login`.
- Ou avec `Navigator.pushNamed(context, '/login')` depuis n'importe quel widget.
