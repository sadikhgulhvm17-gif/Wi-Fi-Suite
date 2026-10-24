#!/bin/bash
echo "🚀 Building Wi-Fi Suite Polyglot Monorepo..."

# 1. إنشاء الهيكل
mkdir -p native/ndk/src
mkdir -p services/go_engine
mkdir -p services/py_analytics
mkdir -p services/spring_api/src/main/java/com/wifisuite
mkdir -p apps/flutter_app/lib
mkdir -p apps/android_compose/app/src/main/java/com/wifisuite
mkdir -p apps/rn_app
mkdir -p infra/k8s

# ==========================================
# 2. طبقة C/NDK (Native Core)
# ==========================================
cat << 'C_EOF' > native/ndk/src/wifi_probe.h
#ifndef WIFI_PROBE_H
#define WIFI_PROBE_H
int wifi_probe_wlan0(void);
int wifi_probe_ipv4(char *out, int cap);
#endif
C_EOF

cat << 'C_EOF' > native/ndk/src/wifi_probe.c
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
C_EOF

# ==========================================
# 3. طبقة الباك إند (Go Engine)
# ==========================================
cat << 'GO_EOF' > services/go_engine/main.go
package main
import ("encoding/json";"net";"net/http")
type Iface struct { Name string `json:"name"`; Up bool `json:"up"`; Addrs []string `json:"addrs"` }
func scan() []Iface {
    out := []Iface{}
    ifs, _ := net.Interfaces()
    for _, i := range ifs {
        a, _ := i.Addrs()
        addrs := []string{}
        for _, x := range a { addrs = append(addrs, x.String()) }
        out = append(out, Iface{i.Name, i.Flags&net.FlagUp != 0, addrs})
    }
    return out
}
func main() {
    http.HandleFunc("/interfaces", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(scan())
    })
    http.ListenAndServe(":8081", nil)
}
GO_EOF

# ==========================================
# 4. طبقة الباك إند (Python Analytics)
# ==========================================
cat << 'PY_EOF' > services/py_analytics/app.py
from flask import Flask, request, jsonify
app = Flask(__name__)
@app.post("/analyze")
def analyze():
    data = request.get_json()
    rssi = data.get("rssi", -70)
    # معادلة بسيطة لتقييم الإشارة
    quality = max(0, min(100, 100 + rssi))
    return jsonify({"quality": quality, "status": "good" if quality > 50 else "poor"})
@app.get("/health")
def health(): return {"ok": True}
if __name__ == '__main__': app.run(host='0.0.0.0', port=8082)
PY_EOF
echo "flask" > services/py_analytics/requirements.txt

# ==========================================
# 5. طبقة الباك إند (Spring Boot - Java)
# ==========================================
cat << 'JAVA_EOF' > services/spring_api/src/main/java/com/wifisuite/App.java
package com.wifisuite;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class App { public static void main(String[] a){ SpringApplication.run(App.class, a);} }
JAVA_EOF

cat << 'JAVA_EOF' > services/spring_api/src/main/java/com/wifisuite/AccessPointController.java
package com.wifisuite;
import org.springframework.web.bind.annotation.*;
import java.util.*;
@RestController
@RequestMapping("/api/ap")
public class AccessPointController {
    public record AP(String ssid, String bssid, int rssi) {}
    private final Map<String, AP> store = new HashMap<>();
    @GetMapping
    public Collection<AP> list() { return store.values(); }
    @PostMapping
    public AP add(@RequestBody AP ap) { store.put(ap.bssid(), ap); return ap; }
}
JAVA_EOF

# ==========================================
# 6. طبقة الواجهات (Flutter & Compose)
# ==========================================
cat << 'DART_EOF' > apps/flutter_app/lib/main.dart
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Text("Wi-Fi Suite UI", textDirection: TextDirection.ltr)));
DART_EOF

cat << 'KT_EOF' > apps/android_compose/app/src/main/java/com/wifisuite/NativeWifi.kt
package com.wifisuite
object NativeWifi {
    init { System.loadLibrary("wifi_probe") }
    external fun isWlan0Up(): Boolean
}
KT_EOF

# ==========================================
# 7. البنية التحتية (Docker Compose)
# ==========================================
cat << 'YAML_EOF' > infra/docker-compose.yml
version: "3.9"
services:
  go_engine:
    image: golang:alpine
    command: go run main.go
    volumes: [ "../services/go_engine:/app" ]
    ports: [ "8081:8081" ]
YAML_EOF

echo "✅ تم إنشاء جميع الأكواد والمجلدات بنجاح!"
