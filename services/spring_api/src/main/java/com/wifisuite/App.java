package com.wifisuite;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@SpringBootApplication
@RestController
@RequestMapping("/api/ap")
public class App {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    public record AP(String ssid, String bssid, int rssi) {}
    private final Map<String, AP> store = new ConcurrentHashMap<>();

    @GetMapping
    public Collection<AP> list() { return store.values(); }

    @PostMapping
    public AP add(@RequestBody AP ap) {
        store.put(ap.bssid(), ap);
        return ap;
    }
}
