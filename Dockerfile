FROM tomcat:10-jdk17

# Install MariaDB (MySQL drop-in replacement) and Maven
RUN apt-get update && \
    apt-get install -y mariadb-server maven && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src
COPY schema.sql .

# Build the project using Maven
RUN mvn clean package -DskipTests

# Clean default webapps, deploy as ROOT.war (for root domain /) and online-voting.war (for /online-voting/)
RUN rm -rf /usr/local/tomcat/webapps/* && \
    cp target/*.war /usr/local/tomcat/webapps/ROOT.war && \
    cp target/*.war /usr/local/tomcat/webapps/online-voting.war

# Disable Tomcat shutdown port (8005) so internal probes don't log 'Invalid shutdown command' warnings
RUN sed -i 's/<Server port="8005"/<Server port="-1"/' /usr/local/tomcat/conf/server.xml

# Expose Tomcat port
EXPOSE 8080

# Environment variables for Tomcat database connection
ENV DB_URL="jdbc:mysql://127.0.0.1:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
ENV DB_USERNAME="root"
ENV DB_PASSWORD="Akash@123"

# Create a startup script that initializes the database then starts Tomcat
RUN echo '#!/bin/bash\n\
echo "Starting Database..."\n\
service mariadb start\n\
sleep 4\n\
echo "Configuring Database for Voting System..."\n\
mysql -e "CREATE DATABASE IF NOT EXISTS online_voting;"\n\
mysql -e "ALTER USER '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\''Akash@123'\''; FLUSH PRIVILEGES;" || mysqladmin -u root password "Akash@123" || true\n\
mysql -u root -pAkash@123 -e "GRANT ALL PRIVILEGES ON *.* TO '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\''Akash@123'\''; GRANT ALL PRIVILEGES ON *.* TO '\''root'\''@'\''127.0.0.1'\'' IDENTIFIED BY '\''Akash@123'\''; FLUSH PRIVILEGES;" || true\n\
mysql -u root -pAkash@123 online_voting < /app/schema.sql\n\
echo "Starting Tomcat..."\n\
/usr/local/tomcat/bin/catalina.sh run\n\
' > /app/start.sh

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
