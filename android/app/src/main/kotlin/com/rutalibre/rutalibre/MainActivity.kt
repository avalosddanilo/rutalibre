package com.rutalibre.rutalibre

import android.app.KeyguardManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.PowerManager
import android.view.WindowManager
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

    // El wakelock que ENCIENDE la pantalla cuando la alarma suena con el
    // teléfono en el bolsillo. Las banderas de ventana
    // (setTurnScreenOn/setShowWhenLocked) hacen que la pantalla de alarma se
    // vea sobre el bloqueo, pero no prenden una pantalla apagada desde una
    // actividad pausada; esto sí.
    private var screenLock: PowerManager.WakeLock? = null

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
                "holdTrip" -> {
                    // El servicio en primer plano: el proceso deja de
                    // congelarse y el GPS sigue llegando con la pantalla
                    // apagada. Ver TripService.
                    try {
                        TripService.start(this@MainActivity)
                        result.success(true)
                    } catch (_: Exception) {
                        // Contesta FALSE y no un error: el lado de Dart usa
                        // esa respuesta para dejar el wakelock de pantalla
                        // como red, que es el comportamiento de la 1.0.
                        result.success(false)
                    }
                }
                "releaseTrip" -> {
                    try {
                        TripService.stop(this@MainActivity)
                    } catch (_: Exception) {
                        // Parar lo que no arrancó no es un problema.
                    }
                    result.success(null)
                }
                "wakeScreen" -> {
                    try {
                        runOnUiThread {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                                setShowWhenLocked(true)
                                setTurnScreenOn(true)
                                val keyguard =
                                    getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                                keyguard.requestDismissKeyguard(this@MainActivity, null)
                            } else {
                                @Suppress("DEPRECATION")
                                window.addFlags(
                                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD,
                                )
                            }
                            // Ya despierto, que no se vuelva a apagar
                            // mientras la alarma esté en pantalla.
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                        releaseScreenLock()
                        @Suppress("DEPRECATION")
                        screenLock = power.newWakeLock(
                            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                                PowerManager.ACQUIRE_CAUSES_WAKEUP,
                            "rutalibre:alarma",
                        ).apply {
                            // Con vencimiento: si algo sale mal y nadie
                            // llama a silence, el wakelock se suelta solo a
                            // los dos minutos en vez de dejar la pantalla
                            // prendida hasta que muera la batería.
                            acquire(2 * 60 * 1000L)
                        }
                    } catch (_: Exception) {
                        // Sin pantalla encendida quedan el tono y la
                        // vibración, que es como despertaba antes.
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
                    // La pantalla vuelve a ser del usuario: soltar el
                    // wakelock y la bandera juntos, o queda prendida para
                    // siempre.
                    releaseScreenLock()
                    runOnUiThread {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Soltar un wakelock que no está tomado TIRA, así que se pregunta. */
    private fun releaseScreenLock() {
        try {
            screenLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {
            // Nada que soltar.
        }
        screenLock = null
    }

    override fun onDestroy() {
        // Si Android mata la actividad con la alarma sonando, el tono no
        // puede quedar huérfano sonando sin pantalla que lo apague.
        alarmPlayer?.release()
        alarmPlayer = null
        chimePlayer?.release()
        chimePlayer = null
        releaseScreenLock()
        super.onDestroy()
    }
}
