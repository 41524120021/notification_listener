package com.notiflistener.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot receiver to auto-start notification listener service
 * Similar to B4A's BOOT_COMPLETED receiver
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            Log.d("BootReceiver", "Device booted, notification listener should auto-start")
            
            // The notification listener service will auto-start
            // No need to manually start it here
        }
    }
}
