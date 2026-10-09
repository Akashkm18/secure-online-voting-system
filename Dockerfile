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

RUN cp target/*.war /usr/local/tomcat/webapps/online-voting.war

# Expose Tomcat port
EXPOSE 8080

# Create a startup script that initializes the database then starts Tomcat
RUN echo '#!/bin/bash\n\
echo "Starting Database..."\n\
service mariadb start\n\
sleep 5\n\
echo "Configuring Database for Voting System..."\n\
mysql -e "CREATE DATABASE IF NOT EXISTS online_voting;"\n\
mysqladmin -u root password "Akash@123" || mysql -e "ALTER USER '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\''Akash@123'\'';"\n\
mysql -u root -pAkash@123 online_voting < /app/schema.sql\n\
echo "Starting Tomcat..."\n\
/usr/local/tomcat/bin/catalina.sh run\n\
' > /app/start.sh

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
