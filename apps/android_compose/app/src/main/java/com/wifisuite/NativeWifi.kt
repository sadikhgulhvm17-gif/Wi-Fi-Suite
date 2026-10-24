package com.wifisuite
object NativeWifi {
    init { System.loadLibrary("wifi_probe") }
    external fun isWlan0Up(): Boolean
}
