/// Genera el sonido de "arrancó el viaje".
///
/// Uso:
///   dart run tools/trip_start_chime.dart
///
/// Escribe `android/app/src/main/res/raw/trip_start.wav`.
///
/// **Por qué se sintetiza y no se baja de un banco de sonidos.** El sonido de
/// notificación del sistema cambia de teléfono en teléfono y en muchos es
/// feo (hallazgo de campo, textual: "malísimo"). Uno bajado de internet trae
/// su licencia y su atribución. Dos notas generadas acá son nuestras, pesan
/// 60 KB y suenan igual en todos lados. Si hay que cambiarlo, se cambian los
/// números de abajo y se regenera.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 44100;

/// Dos notas que SUBEN —una quinta justa, Mi a Si—: subir se lee como
/// "empezó", bajar como "terminó". Es el mismo lenguaje de los sonidos de
/// inicio de viaje de las apps de transporte.
const _notes = [
  (hz: 659.25, start: 0.00), // Mi5
  (hz: 987.77, start: 0.11), // Si5
];

/// Cuánto dura cada nota hasta apagarse.
const _noteSeconds = 0.55;

/// Volumen máximo: -7 dB. Fuerte para oírse en la vereda, sin saturar
/// cuando las dos notas se superponen.
const _peak = 0.45;

void main() {
  const totalSeconds = 0.11 + _noteSeconds + 0.05;
  final frames = (totalSeconds * _sampleRate).round();
  final samples = Float64List(frames);

  for (final note in _notes) {
    final first = (note.start * _sampleRate).round();
    final length = (_noteSeconds * _sampleRate).round();
    for (var i = 0; i < length && first + i < frames; i++) {
      final t = i / _sampleRate;
      // Ataque de 6 ms (sin el "click" de arrancar en seco) y caída
      // exponencial: la envolvente de una campanita, no de un pitido.
      final attack = math.min(1.0, t / 0.006);
      final decay = math.exp(-t * 7.5);
      // La fundamental más un toque de la octava: le da cuerpo sin volverlo
      // metálico.
      final tone =
          math.sin(2 * math.pi * note.hz * t) +
          0.18 * math.sin(2 * math.pi * note.hz * 2 * t);
      samples[first + i] += tone * attack * decay;
    }
  }

  // Normalizado al pico elegido, sea cual sea la superposición.
  var maxAbs = 0.0;
  for (final s in samples) {
    maxAbs = math.max(maxAbs, s.abs());
  }
  final gain = _peak / maxAbs;

  final pcm = ByteData(frames * 2);
  for (var i = 0; i < frames; i++) {
    final value = (samples[i] * gain * 32767).round().clamp(-32768, 32767);
    pcm.setInt16(i * 2, value, Endian.little);
  }

  final wav = _wavHeader(dataBytes: frames * 2);
  final out = File('android/app/src/main/res/raw/trip_start.wav');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync([...wav, ...pcm.buffer.asUint8List()]);
  stdout.writeln(
    '${out.path} escrito (${(out.lengthSync() / 1024).toStringAsFixed(0)} KB, '
    '${totalSeconds.toStringAsFixed(2)} s).',
  );
}

/// Encabezado WAV PCM de 16 bits, mono.
List<int> _wavHeader({required int dataBytes}) {
  final header = ByteData(44);
  void ascii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      header.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + dataBytes, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little); // tamaño del bloque fmt
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // mono
  header.setUint32(24, _sampleRate, Endian.little);
  header.setUint32(28, _sampleRate * 2, Endian.little); // bytes/seg
  header.setUint16(32, 2, Endian.little); // bytes por muestra
  header.setUint16(34, 16, Endian.little); // bits
  ascii(36, 'data');
  header.setUint32(40, dataBytes, Endian.little);
  return header.buffer.asUint8List();
}
