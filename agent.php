<?php
/**
 * وكيل ذكاء اصطناعي (PHP Agent) - Security Edition
 * يعمل مباشرة عبر CLI في بيئة Termux
 */

$apiKey = "YOUR_API_KEY_HERE";
$apiUrl = "https://api.openai.com/v1/chat/completions";

echo "========================================\n";
echo "   AI Agent (PHP) - Security Edition\n";
echo "========================================\n";
echo "يحتوي الوكيل على سياق لـ CVE-2026-109619 و CVE-2026-109618\n\n";

while (true) {
    echo "\nأنت > ";
    $input = trim(fgets(STDIN));

    if (strtolower($input) === 'exit') {
        echo "إلى اللقاء!\n";
        break;
    }

    if (empty($input)) {
        continue;
    }

    $data = [
        "model" => "gpt-3.5-turbo",
        "messages" => [
            [
                "role" => "system", 
                "content" => "أنت وكيل ذكاء اصطناعي خبير في أمن المعلومات وإدارة الأنظمة. لديك معرفة تحليلية متقدمة وتتعامل مع الثغرات الأمنية المحددة مثل CVE-2026-109619 و CVE-2026-109618 بغرض التحليل الفني، الفحص، أو الحماية."
            ],
            ["role" => "user", "content" => $input]
        ]
    ];

    $ch = curl_init($apiUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Content-Type: application/json",
        "Authorization: Bearer " . $apiKey
    ]);

    $response = curl_exec($ch);
    $err = curl_error($ch);
    curl_close($ch);

    if ($err) {
        echo "خطأ في الاتصال: " . $err . "\n";
        continue;
    }

    $result = json_decode($response, true);
    $reply = $result['choices'][0]['message']['content'] ?? 'لم يتم استلام رد صحيح.';

    echo "\nالوكيل الذكي > " . $reply . "\n";
}
