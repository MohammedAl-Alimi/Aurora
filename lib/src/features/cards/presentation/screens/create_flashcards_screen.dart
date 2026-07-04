import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:quizwiz/src/core/core.dart';
import 'package:quizwiz/src/features/cards/controller/controller.dart';
import 'package:quizwiz/src/features/cards/presentation/presentation.dart';

class CreateFlashcardsScreen extends StatefulWidget {
  final String collectionUuid;
  const CreateFlashcardsScreen({
    super.key,
    required this.collectionUuid,
  });

  @override
  State<CreateFlashcardsScreen> createState() => _CreateFlashcardsScreenState();
}

class _CreateFlashcardsScreenState extends State<CreateFlashcardsScreen> {
  late final TextEditingController questionController;
  late final TextEditingController answerController;
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    questionController = TextEditingController();
    answerController = TextEditingController();
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  bool _addFlashcard() {
    if (key.currentState!.validate()) {
      context.read<CardsBloc>().add(AddFlashcardsEvent(
          collectionUuid: widget.collectionUuid,
          question: questionController.text,
          answer: answerController.text));
      return true; //if card was added successfully, return true to navigate
    }
    return false;
  }

  void generateFlashcards(File? file) {
    if (file != null) {
      context.read<CardsBloc>().add(GenerateFlashcardsEvent(file: file));
      Navigator.of(context).pushReplacementNamed(Routes.generatedFlashcards,
          arguments: widget.collectionUuid);
    } else {
      customSnackBar("No File was selected", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.createFlashcards),
        ),
        body: LayoutBuilder(
            builder: (context, size) => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SizedBox(
                      height: size.maxHeight * 0.2,
                    ),
                    CustomForms(
                        formKey: key,
                        questionController: questionController,
                        answerController: answerController),
                    // PDF/AI generation relies on native plugins that don't
                    // run on web — offer it only where it works.
                    if (!kIsWeb)
                      TextButton.icon(
                          key: const Key(AppStrings.generateWithAI),
                          onPressed: () async {
                            final file = await _pickFile();
                            generateFlashcards(file);
                          },
                          icon: const Icon(Icons.rocket),
                          label: const Text(AppStrings.generateWithAI)),
                    TextButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                            Routes.pasteImport,
                            arguments: widget.collectionUuid),
                        icon: const Icon(Icons.content_paste),
                        label: const Text('Paste text to add many')),
                    SizedBox(height: size.maxHeight * 0.15),
                    FilledButton(
                        key: const Key(AppStrings.addCard),
                        onPressed: () {
                          if (_addFlashcard()) {
                            Navigator.of(context).pushReplacementNamed(
                                Routes.flashcardsList,
                                arguments: widget.collectionUuid);
                          }
                        },
                        child: const Text(AppStrings.addCard)),
                    const SizedBox(
                      height: 20,
                    ),
                    FilledButton(
                        key: const Key(AppStrings.addAnotherCard),
                        onPressed: () {
                          if (_addFlashcard()) {
                            Navigator.of(context).pushReplacementNamed(
                                Routes.createFlashcards,
                                arguments: widget.collectionUuid);
                          }
                        },
                        child: const Text(AppStrings.addAnotherCard)),
                  ],
                )));
  }
}

Future<File?> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
  if (result != null) {
    return File(result.files.single.path!);
  }
  return null;
}
