<<<<<<< HEAD
package org.openfoodfacts.app
=======
package com.luppaapp.app
>>>>>>> 33fe57b5c (Primer commit)

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
<<<<<<< HEAD
import org.openfoodfacts.app.MainActivity
=======
import com.luppaapp.app.MainActivity
>>>>>>> 33fe57b5c (Primer commit)

@RequiresApi(Build.VERSION_CODES.N)
class AppMainTile : TileService() {

    override fun onStartListening() {
        super.onStartListening()

        qsTile.state = Tile.STATE_INACTIVE
        qsTile.updateTile()
    }

    override fun onClick() {
        super.onClick()

        val intent = Intent(this, MainActivity::class.java).apply {
            flags += Intent.FLAG_ACTIVITY_NEW_TASK
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(
                PendingIntent.getActivity(
                    applicationContext,
                    0,
                    intent,
                    PendingIntent.FLAG_IMMUTABLE
                )
            )
        } else {
            startActivityAndCollapse(intent)
        }
    }

}