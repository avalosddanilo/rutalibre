package com.rutalibre.rutalibre

import android.media.AudioAttributes
import android.media.AudioManager
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

    // Referencia viva al del "arrancó el viaje": un MediaPlayer sin nadie
    // que lo sostenga puede recolectarse a mitad del sonido y cortarlo.
    private var chimePlayer: MediaPlayer? = null

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
                    // El "arrancó el viaje": el sonido PROPIO de la app
                    // (res/raw/trip_start.wav, generado por
                    // tools/trip_start_chime.dart). El de notificación del
                    // sistema cambia en cada teléfono y en muchos es feo.
                    //
                    // Respeta el modo silencio y el de vibración a mano, sin
                    // depender de cómo cada fabricante trate el canal: un
                    // aviso de que algo empezó no justifica sonar en una
                    // reunión. Solo la alarma de bajada lo atraviesa.
                    try {
                        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
                        if (audio.ringerMode == AudioManager.RINGER_MODE_NORMAL) {
                            chimePlayer?.release()
                            chimePlayer = MediaPlayer().apply {
                                setAudioAttributes(
                                    AudioAttributes.Builder()
                                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                        .build(),
                                )
                                val sound = resources.openRawResourceFd(R.raw.trip_start)
                                setDataSource(sound.fileDescriptor, sound.startOffset, sound.length)
                                sound.close()
                                setOnCompletionListener {
                                    it.release()
                                    chimePlayer = null
                                }
                                prepare()
                                start()
                            }
                        }
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
        chimePlayer?.release()
        chimePlayer = null
        super.onDestroy()
    }
}
