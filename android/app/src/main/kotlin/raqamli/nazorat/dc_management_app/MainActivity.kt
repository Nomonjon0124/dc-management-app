package raqamli.nazorat.dc_management_app

import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intent = Intent(this, MeetingAudioForegroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }

                "stop" -> {
                    stopService(Intent(this, MeetingAudioForegroundService::class.java))
                    result.success(null)
                }

                "startScreenShareForegroundService" -> {
                    MeetingScreenShareForegroundService.pendingStartResult = result
                    try {
                        val intent = Intent(
                            this,
                            MeetingScreenShareForegroundService::class.java,
                        )
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            ContextCompat.startForegroundService(this, intent)
                        } else {
                            startService(intent)
                        }
                    } catch (error: Throwable) {
                        MeetingScreenShareForegroundService.pendingStartResult = null
                        result.error(
                            "SCREEN_SHARE_FOREGROUND_SERVICE_START_FAILED",
                            error.message,
                            null,
                        )
                    }
                }

                "stopScreenShareForegroundService" -> {
                    MeetingScreenShareForegroundService.pendingStartResult = null
                    stopService(
                        Intent(this, MeetingScreenShareForegroundService::class.java),
                    )
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    companion object {
        const val CHANNEL = "raqamli.nazorat/meeting_audio"
    }
}
