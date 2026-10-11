#!/bin/bash
set -e

echo "=== [STARTUP] Starting MariaDB Database Server ==="
service mariadb start || /etc/init.d/mariadb start || mysqld_safe &

# Wait up to 30 seconds for MariaDB to accept connections
echo "=== [STARTUP] Waiting for MariaDB socket to open ==="
for i in $(seq 1 30); do
    if mysqladmin ping --silent 2>/dev/null; then
        echo "=== [STARTUP] MariaDB is up and healthy ==="
        break
    fi
    sleep 1
done

echo "=== [STARTUP] Configuring Database & Credentials ==="
mysql -e "CREATE DATABASE IF NOT EXISTS online_voting CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Akash@123'; FLUSH PRIVILEGES;" 2>/dev/null || mysqladmin -u root password "Akash@123" 2>/dev/null || true
mysql -u root -pAkash@123 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'Akash@123'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY 'Akash@123'; FLUSH PRIVILEGES;" 2>/dev/null || true

echo "=== [STARTUP] Executing schema.sql migrations ==="
mysql -u root -pAkash@123 online_voting < /app/schema.sql 2>/dev/null || true

# Dynamic Render PORT Configuration
PORT="${PORT:-8080}"
echo "=== [STARTUP] Configuring Tomcat port to ${PORT} ==="
sed -i "s/port=\"[0-9]*\" protocol=\"HTTP\/1.1\"/port=\"${PORT}\" protocol=\"HTTP\/1.1\"/g" /usr/local/tomcat/conf/server.xml || true
sed -i "s/Connector port=\"8080\"/Connector port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml || true

# Ensure maxPostSize is large enough (25MB) so camera & photo uploads are never dropped by Tomcat
sed -i "s/<Connector port=\"${PORT}\"/<Connector port=\"${PORT}\" maxPostSize=\"26214400\"/g" /usr/local/tomcat/conf/server.xml || true

echo "=== [STARTUP] Launching Apache Tomcat on port ${PORT} ==="
exec /usr/local/tomcat/bin/catalina.sh run
