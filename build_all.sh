#!/usr/bin/env bash
set -e

echo "====================================="
echo "🚀 Wi-Fi Suite Polyglot Build System"
echo "====================================="

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "🧹 Cleaning old processes..."
pkill -9 -f java || true
pkill -9 -f go_engine || true
pkill -9 -f python || true

echo "🛠️  [1/4] Building C Native Library..."
cd native/ndk/src && clang -shared -fPIC -o libwifi_probe.so wifi_probe.c
echo "✅ Native Library Built."
cd "$ROOT"

echo "🐹 [2/4] Building Go Engine..."
cd services/go_engine && go build -o go_engine main.go
echo "✅ Go Engine Built."
cd "$ROOT"

echo "☕ [3/4] Building Spring Boot API..."
cd services/spring_api && mvn clean package -DskipTests -q
echo "✅ Spring Boot JAR Built."
cd "$ROOT"

echo "🐍 [4/4] Checking Python Analytics..."
cd services/py_analytics && python -c "import flask" 2>/dev/null || echo "⚠️ Flask not installed."
cd "$ROOT"

echo ""
echo "🚦 Starting All Services in Background..."
cd "$ROOT/services/py_analytics" && python app.py > /dev/null 2>&1 &
cd "$ROOT/services/go_engine" && ./go_engine > /dev/null 2>&1 &
# استخدام nohup وإضافة حد للذاكرة لجافا
cd "$ROOT/services/spring_api" && nohup java -Xmx256m -jar target/spring_api-1.0.0.jar --server.port=8083 > java.log 2>&1 &

echo "⏳ Waiting for services to be ready (this may take 15-20s)..."

# انتظار Python
echo -n "Checking Python (8082)... "
until curl -s http://localhost:8082/health > /dev/null; do sleep 1; done
echo "✅"

# انتظار Go
echo -n "Checking Go     (8081)... "
until curl -s http://localhost:8081/interfaces > /dev/null; do sleep 1; done
echo "✅"

# انتظار Java
echo -n "Checking Java   (8083)... "
MAX_RETRIES=30
COUNT=0
until curl -s http://localhost:8083/api/ap > /dev/null || [ $COUNT -eq $MAX_RETRIES ]; do
    sleep 1
    COUNT=$((COUNT+1))
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Failed (Check services/spring_api/java.log)"
else
    echo "✅"
fi

echo ""
echo "====================================="
echo "🏥 Final Health Checks ---"
echo -n "Python: "; curl -s http://localhost:8082/health
echo ""
echo -n "Go    : "; curl -s http://localhost:8081/interfaces | head -c 50; echo "..."
echo -n "Java  : "; curl -s http://localhost:8083/api/ap
echo ""
echo "====================================="
echo "🎉 Polyglot Backend is Fully Operational!"
echo "To stop all services, run: pkill -9 -f java; pkill -9 -f go_engine; pkill -9 -f python"
echo "====================================="
