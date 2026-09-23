package raqamli.nazorat.dc_management_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import io.flutter.plugin.common.MethodChannel

class MeetingScreenShareForegroundService : Service() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
                )
            } else {
                startForeground(NOTIFICATION_ID, notification())
            }
        } catch (error: Throwable) {
            completeStartWithError(error)
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        completeStartSuccessfully()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Ekran ulashish",
            NotificationManager.IMPORTANCE_LOW,
        )
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun notification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setContentTitle("Ekran ulashilmoqda")
            .setContentText("Uchrashuvda ekraningiz ko‘rsatilmoqda")
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .apply { if (pendingIntent != null) setContentIntent(pendingIntent) }
            .build()
    }

    private fun completeStartSuccessfully() {
        val result = pendingStartResult ?: return
        pendingStartResult = null
        result.success(null)
    }

    private fun completeStartWithError(error: Throwable) {
        val result = pendingStartResult ?: return
        pendingStartResult = null
        result.error(
            "SCREEN_SHARE_FOREGROUND_SERVICE_START_FAILED",
            error.message,
            null,
        )
    }

    companion object {
        private const val CHANNEL_ID = "meeting_screen_share"
        private const val NOTIFICATION_ID = 4102

        @Volatile
        var pendingStartResult: MethodChannel.Result? = null
    }
}
