#include "wifi_probe.h"
#include <stdio.h>
#include <string.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <sys/socket.h>

int wifi_probe_wlan0(void) {
    struct ifaddrs *ifs = NULL;
    if (getifaddrs(&ifs) != 0) return 0;
    int up = 0;
    for (struct ifaddrs *p = ifs; p; p = p->ifa_next) {
        if (p->ifa_name && strcmp(p->ifa_name, "wlan0") == 0) {
            if (p->ifa_flags & IFF_UP) up = 1;
        }
    }
    freeifaddrs(ifs);
    return up;
}

int wifi_probe_ipv4(char *out, int cap) {
    struct ifaddrs *ifs = NULL;
    if (getifaddrs(&ifs) != 0) return -1;
    int rc = -1;
    for (struct ifaddrs *p = ifs; p; p = p->ifa_next) {
        if (!p->ifa_addr || p->ifa_addr->sa_family != AF_INET) continue;
        if (strcmp(p->ifa_name, "wlan0") == 0) {
            struct sockaddr_in *sin = (struct sockaddr_in*)p->ifa_addr;
            if (inet_ntop(AF_INET, &sin->sin_addr, out, cap)) rc = 0;
            break;
        }
    }
    freeifaddrs(ifs);
    return rc;
}
