package com.rutalibre.rutalibre

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * El servicio que mantiene vivo un viaje guiado con la pantalla apagada.
 *
 * **Por qué existe.** Hasta la 1.0 la alarma "avisame para bajar" obligaba a
 * dejar la pantalla prendida, y estaba avisado en la app y en la ficha de
 * Play. El motivo no era capricho: con la pantalla apagada Android manda el
 * proceso a segundo plano, lo congela, y el GPS deja de llegar — la alarma no
 * es que suene bajo, es que nunca se entera de que llegaste. Quien se durmió
 * con el teléfono en el bolsillo, que es EXACTAMENTE para quien se hizo la
 * alarma, se pasaba de parada igual.
 *
 * ⚠️ **Esto solo, NO alcanza.** Probado en emulador el 2026-09-21: el
 * servicio arranca bien y el GPS sigue llegando, pero la alarma igual no
 * suena hasta encender la pantalla, porque la DECISIÓN de sonar vive adentro
 * de `build()` del lado de Dart y Flutter no dibuja cuadros con la pantalla
 * apagada. Lo de acá está bien y no hay que tocarlo; lo que falta está en
 * `docs/alarma-pantalla-apagada.md`.
 *
 * Un servicio en primer plano con tipo `location` es la única forma que da
 * Android de decir "este proceso no se congela y sigue recibiendo ubicación".
 * El precio es la notificación fija, que no se puede sacar: es el trato, y
 * está bien que sea así — el usuario tiene que ver que algo suyo está usando
 * el GPS.
 *
 * **Por qué propio y no el de geolocator.** `geolocator_android` trae su
 * propio servicio (`GeolocatorLocationService`, se ve en el manifest
 * fusionado) que se enciende pasándole `foregroundNotificationConfig` a
 * `AndroidSettings`. Sería menos código. No se usa porque ese servicio vive
 * exactamente lo que vive la suscripción al stream, y en esta app el stream
 * está prendido durante TODO viaje guiado — con alarma o sin ella. Eso le
 * pondría una notificación fija en la barra a alguien que solo quiso ver
 * cuántas paradas faltan. Así, la notificación aparece únicamente cuando el
 * usuario arma la alarma, que es cuando pidió que su teléfono siga
 * trabajando en el bolsillo.
 *
 * **Dura lo que dura el viaje.** Arranca al armar la alarma y se va al
 * desarmarla o al terminar la guía ([WakeAlarmNotifier] en Dart es el único
 * dueño). `START_NOT_STICKY` a propósito: si el sistema lo mata por presión
 * de memoria, NO queremos que reviva solo horas después con un viaje que ya
 * terminó.
 */
class TripService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            val notification = buildNotification()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                // Android 14 exige declarar el tipo acá y en el manifest, y
                // tener el permiso de ubicación YA concedido: si no, tira.
                startForeground(
                    NOTIF_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
                )
            } else {
                startForeground(NOTIF_ID, notification)
            }
        } catch (_: Exception) {
            // Sin servicio la app queda como estaba en la 1.0 —la alarma
            // anda con la pantalla prendida— en vez de morirse. El lado de
            // Dart ya dejó el wakelock puesto como red.
            stopSelf()
            return START_NOT_STICKY
        }
        return START_NOT_STICKY
    }

    private fun buildNotification(): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // IMPORTANCE_LOW: sin sonido ni vibración. La notificación del
            // viaje no avisa nada todavía — la que despierta es la alarma, y
            // esa va por el canal de alarmas del sistema. Una notificación
            // fija que hace ruido cada vez que aparece sería insoportable.
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Viaje en curso",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Mientras te llevamos a tu parada, para que la " +
                    "alarma funcione con la pantalla apagada."
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        // Tocar la notificación devuelve a la app, al viaje que ya está
        // abierto: `singleTop` en el manifest evita abrir una segunda.
        val abrir = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("Viaje en curso")
            .setContentText("Te aviso cuándo bajarte. Podés apagar la pantalla.")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(abrir)
            .setOngoing(true)
            .setShowWhen(false)
            .build()
    }

    companion object {
        private const val CHANNEL_ID = "rutalibre.viaje"

        /** Uno solo: nunca hay dos viajes guiados a la vez. */
        private const val NOTIF_ID = 1

        fun start(context: Context) {
            val intent = Intent(context, TripService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, TripService::class.java))
        }
    }
}
