<p align="center">
  <img src="assets/icon.jpeg" alt="Aurora" width="112" />
</p>

<h1 align="center">Aurora</h1>

<p align="center">
  <b>A smart flashcard app that uses AI to generate flashcards from your documents —<br/>
  so you can spend less time making cards and more time learning.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/architecture-Bloc%20%2B%20Clean-4CAF50" alt="Architecture" />
  <img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="License" />
</p>

---

**Aurora** turns a PDF (or pasted text) into a study deck you can review with spaced repetition. Built with Flutter using a clean, layered architecture (Bloc + repository pattern).

## ✨ Features

- **AI flashcard generation** — create decks automatically from PDFs or pasted text
- **Spaced repetition** — review with the proven **SM-2** algorithm
- **Practice modes** — multiple-choice quizzes and manual (writing) recall
- **Deck management** — create, edit, and organize flashcard collections
- **Offline-first** — cards stored locally with the Isar database
- **Light & dark themes** for comfortable studying

## 🧱 Tech & architecture

| Concern | Choice |
|---|---|
| Architecture | Clean architecture (data / domain / presentation) |
| State management | `flutter_bloc` (Bloc pattern) |
| Dependency injection | `get_it` |
| Local database | `isar` |
| Theming | `flex_color_scheme` |
| Networking | `dio` |
| PDF / OCR | `read_pdf_text`, `google_ml_vision` |
| AI backend | [ChatPDF API](https://www.chatpdf.com/docs/api/backend) |

```
lib/src/
├── core/                  # shared building blocks
│   ├── errors/            # failures & exceptions
│   ├── router/            # route generation
│   ├── services/          # DI + connectivity
│   ├── theme/             # dynamic theming
│   ├── utils/             # constants, enums, strings
│   └── widgets/           # shared widgets
└── features/cards/
    ├── controller/        # Bloc (state management)
    ├── data/              # models, data sources, repositories
    └── presentation/      # screens & widgets
```

## 🚀 Getting started

**Prerequisites:** [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ≥ 3.0.3).

```bash
# 1. Clone
git clone https://github.com/MohammedAl-Alimi/Auroura.git
cd Auroura

# 2. Install dependencies
flutter pub get
```

**3. Add your API keys.** Aurora uses the [ChatPDF API](https://www.chatpdf.com/docs/api/backend)
to generate flashcards. Copy the example env file and fill in your keys:

```bash
cp .env.example .env
```

Then edit `.env`:

```
chatPdfApi=your_chatpdf_api_key
RAPID_API_KEY=your_rapidapi_key
```

> The `.env` file is gitignored and bundled as a Flutter asset at build time —
> never commit real keys.

**4. Run**

```bash
flutter run
```

## 🗺️ Roadmap

- ✅ Spaced repetition (SM-2)
- ✅ Multiple-choice practice mode
- ⏳ Improved AI flashcard generation
- ⏳ UI/UX polish and animations

## 🤝 Contributing

Contributions are welcome — feel free to open an issue or a pull request for
features, fixes, or ideas.

## 📄 License

Released under the [MIT License](LICENSE) © 2025 Mohammed Al-Alimi.
