#include <stdio.h>
#include "wifi_probe.h"

int main() {
    printf("--- Native Wi-Fi Probe (C) ---\n");
    
    // فحص هل واجهة wlan0 تعمل؟
    int is_up = wifi_probe_wlan0();
    printf("wlan0 is UP? : %s\n", is_up ? "YES" : "NO");
    
    // سحب عنوان IP
    char ip_buffer[64];
    if (wifi_probe_ipv4(ip_buffer, sizeof(ip_buffer)) == 0) {
        printf("wlan0 IPv4   : %s\n", ip_buffer);
    } else {
        printf("wlan0 IPv4   : Not found\n");
    }
    
    return 0;
}
