//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_native_timezone/flutter_native_timezone_web.dart';
import 'package:flutter_sound_web/flutter_sound_web.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:speech_to_text/speech_to_text_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  FlutterNativeTimezonePlugin.registerWith(registrar);
  FlutterSoundPlugin.registerWith(registrar);
  FlutterTtsPlugin.registerWith(registrar);
  SpeechToTextPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
