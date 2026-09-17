package com.rutalibre.rutalibre

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // El tono de la alarma "avisame para bajar". Nativo y no un plugin a
    // propósito: lo único que se necesita es "el tono de alarma del sistema,
    // en loop, por el canal de alarmas", y eso son estas líneas. (El plugin
    // que lo hacía compilaba contra Android 33 y rompía el build de release.)
    private var alarmPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rutalibre/alarm",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "ring" -> {
                    // Nunca falla hacia Dart: la alarma sin tono sigue
                    // vibrando y llenando la pantalla, que ya despierta.
                    try {
                        val uri =
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        alarmPlayer?.release()
                        alarmPlayer = MediaPlayer().apply {
                            setDataSource(this@MainActivity, uri)
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    // USAGE_ALARM: el canal de alarmas, que
                                    // suena aunque el teléfono esté en
                                    // silencio — el modo silencio corta el
                                    // canal de llamadas, no este.
                                    .setUsage(AudioAttributes.USAGE_ALARM)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                    .build(),
                            )
                            isLooping = true
                            prepare()
                            start()
                        }
                    } catch (_: Exception) {
                        alarmPlayer = null
                    }
                    result.success(null)
                }
                "chime" -> {
                    // El "arrancó el viaje": el sonido de NOTIFICACIÓN del
                    // sistema, una sola vez. A propósito no es el canal de
                    // alarmas: un aviso de que algo empezó tiene que
                    // respetar el modo silencio — solo la alarma lo atraviesa.
                    try {
                        val uri =
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                        RingtoneManager.getRingtone(this, uri)?.play()
                    } catch (_: Exception) {
                        // Sin sonido, la vibración del lado de Dart avisa igual.
                    }
                    result.success(null)
                }
                "silence" -> {
                    try {
                        alarmPlayer?.stop()
                    } catch (_: Exception) {
                        // Pararlo sin que haya arrancado no es un problema.
                    }
                    alarmPlayer?.release()
                    alarmPlayer = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // Si Android mata la actividad con la alarma sonando, el tono no
        // puede quedar huérfano sonando sin pantalla que lo apague.
        alarmPlayer?.release()
        alarmPlayer = null
        super.onDestroy()
    }
}
