// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/homescreen.dart';


final pallatte = Pallatte();
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  final TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  String _selectedLanguage = 'Spanish'; // Default selection
  bool _isLoading = false;
  bool isLoading = false;
  bool _isLanguageLoading = true;
  bool _removeFocusedBorder = false;
  bool _showTranslation = false;
  bool _hasGenerated = false;
  final List<String> languages = [
    "Auto Detect",
    "Afrikaans",
    "Albanian",
    "Amharic",
    "Arabic",
    "Armenian",
    "Azerbaijani",
    "Basque",
    "Belarusian",
    "Bengali",
    "Bosnian",
    "Bulgarian",
    "Catalan",
    "Cebuano",
    "Chinese (Simplified)",
    "Chinese (Traditional)",
    "Corsican",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "English",
    "Esperanto",
    "Estonian",
    "Finnish",
    "French",
    "Frisian",
    "Galician",
    "Georgian",
    "German",
    "Greek",
    "Gujarati",
    "Haitian Creole",
    "Hausa",
    "Hawaiian",
    "Hebrew",
    "Hindi",
    "Hmong",
    "Hungarian",
    "Icelandic",
    "Igbo",
    "Indonesian",
    "Irish",
    "Italian",
    "Japanese",
    "Javanese",
    "Kannada",
    "Kazakh",
    "Khmer",
    "Kinyarwanda",
    "Korean",
    "Kurdish (Kurmanji)",
    "Kurdish (Sorani)",
    "Kyrgyz",
    "Lao",
    "Latin",
    "Latvian",
    "Lithuanian",
    "Luxembourgish",
    "Macedonian",
    "Malagasy",
    "Malay",
    "Malayalam",
    "Maltese",
    "Maori",
    "Marathi",
    "Mongolian",
    "Myanmar (Burmese)",
    "Nepali",
    "Norwegian",
    "Nyanja (Chichewa)",
    "Odia (Oriya)",
    "Pashto",
    "Persian",
    "Polish",
    "Portuguese (Portugal, Brazil)",
    "Punjabi",
    "Romanian",
    "Russian",
    "Samoan",
    "Scots Gaelic",
    "Serbian",
    "Sesotho",
    "Shona",
    "Sindhi",
    "Sinhala (Sinhalese)",
    "Slovak",
    "Slovenian",
    "Somali",
    "Spanish",
    "Sundanese",
    "Swahili",
    "Swedish",
    "Tagalog (Filipino)",
    "Tajik",
    "Tamil",
    "Tatar",
    "Telugu",
    "Thai",
    "Turkish",
    "Turkmen",
    "Ukrainian",
    "Urdu",
    "Uyghur",
    "Uzbek",
    "Vietnamese",
    "Welsh",
    "Xhosa",
    "Yiddish",
    "Yoruba",
    "Zulu",
  ];

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(vsync: this,duration: const Duration(seconds: 6));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.bottomRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft), 
        weight: 1,
        )
      ],
      ).animate(_controller1);

  _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end:Alignment.bottomRight),
        weight: 1,
        )
      ],
      ).animate(_controller1);

      _controller1.repeat();
  }
  
  
  

  void _translate() async {
  final translationService = TranslationService('AIzaSyAi4ERsu7c8fNE2tghb1gmpq6MetqgcPuM');
  final text = _controller.text.trim();
  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter text to translate')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
    _translatedText = '';
    _showTranslation = false;
    _hasGenerated = true;
  });

  try {
    final translated = await translationService.translateText(text, _selectedLanguage);
    setState(() {
      _translatedText = translated ?? 'No text found';
      _showTranslation = true;
      _hasGenerated = true;
    });
  } catch (e) {
    setState(() {
      _translatedText = 'Error: ${e.toString()}';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _controller1,
        builder: (context,_) {
          return Container(
          decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:_topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [pallatte.backgroundColor1, pallatte.backgroundColor2],
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:<Widget> [
                AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Language Translator',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFE4B5),
          ),
        ),
        centerTitle: true,
        leading: Builder(
                builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFFFFE4B5),
                onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>  const Homescreen(),
        ));
                  },
                  );
                  },
                  ),
      ),const SizedBox(height: 20),
            SingleChildScrollView(
              child: Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 205, 226, 226),
                        borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.circular(40),
              topLeft: Radius.circular(40),
              topRight: Radius.zero,
                        ),
                      ),
                      child: Text(
                      "Welcome, Need help with translations on the go? Our AI-powered language translator is here to assist. Whether you're asking for directions to the nearest washroom, looking for a restaurant, or need help communicating, just type your query, and we'll provide an instant translation!",
              style: const TextStyle(
              fontFamily: 'OpenSans',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children:<Widget> [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 247, 240, 229),
                              border: Border.all(),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.zero,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 0.0),
                              child: TextField(
                                controller: _controller,
                                onTap: () {
                                  setState(() {
                                    _removeFocusedBorder = true;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: _removeFocusedBorder ? InputBorder.none : null,
                                  labelText: _removeFocusedBorder ? null : 'Enter text to translate',
                                ),
                                maxLines: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Select Language:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[50],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedLanguage,
                                style:const TextStyle(
                                  
                                  color: Color.fromARGB(255, 62, 153, 148),
                                  fontWeight: FontWeight.bold
                                ) ,
                                icon: const Icon(Icons.arrow_drop_down, size: 20),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white,width:2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                                  isDense: true,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedLanguage = newValue!;
                                  });
                                },
                                items: languages.map<DropdownMenuItem<String>>(
                                  (String language) {
                                    return DropdownMenuItem<String>(
                                      value: language,
                                      child: Text(
                                        language,
                                        style: const TextStyle(fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GradientButton(
                    
                    buttonText: 'Translate',
                    onPressed: _translate,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading) ...[
                  Center(
                    child: Lottie.asset(
                                  'assets/animation/loading1.json',
                                  height: 80,
                                  width: 80,
                                ),
                  ),
                ] else ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          if(_hasGenerated)...[
                          Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 247, 240, 229),
                                border: Border.all(),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.zero,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: MarkdownBody(
                                  data: _translatedText,
                                  styleSheet: MarkdownStyleSheet(
                                    h2: const TextStyle(
                                      fontFamily: 'Nato Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Color.fromARGB(255, 16, 0, 109),
                                    ),
                                    p: const TextStyle(
                                      fontFamily: 'Nato Sans',
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 16, 0, 109),
                                    ),
                                    strong: const TextStyle(
                                      fontFamily: 'Nato Sans',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    listBullet: const TextStyle(
                                      fontFamily: 'Nato Sans',
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 16, 0, 109),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        }
      ),
    );
  }
}

class TranslationService {
  final GenerativeModel _model;
  TranslationService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );


  Future<String?> translateText(String text, String targetLanguage) async {
    final prompt = "Convert $text to $targetLanguage,only provide the translated text";

    final response = await _model.generateContent(
      [Content.text(prompt)],
    );

    if (response.error != null) {
      throw Exception('Failed to generate translation: ${response.error!.message}');
    }

    final transtext = response.text;
    return transtext;
  }


}

extension on GenerateContentResponse {
  get error => null;
}