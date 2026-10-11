FROM tomcat:10-jdk17

# Install MariaDB (MySQL drop-in replacement), Maven and dos2unix
RUN apt-get update && \
    apt-get install -y mariadb-server maven dos2unix && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src
COPY schema.sql .
COPY start.sh /app/start.sh

# Build the project using Maven
RUN mvn clean package -DskipTests

# Clean default webapps, deploy as ROOT.war (for root domain /) and online-voting.war (for /online-voting/)
RUN rm -rf /usr/local/tomcat/webapps/* && \
    cp target/*.war /usr/local/tomcat/webapps/ROOT.war && \
    cp target/*.war /usr/local/tomcat/webapps/online-voting.war

# Disable Tomcat shutdown port (8005) so internal probes don't log 'Invalid shutdown command' warnings
RUN sed -i 's/<Server port="8005"/<Server port="-1"/' /usr/local/tomcat/conf/server.xml

# Ensure start.sh has Unix line endings and is executable
RUN dos2unix /app/start.sh && chmod +x /app/start.sh

# Expose Tomcat ports
EXPOSE 8080 10000

# Environment variables for Tomcat database connection
ENV DB_URL="jdbc:mysql://127.0.0.1:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
ENV DB_USERNAME="root"
ENV DB_PASSWORD="Akash@123"

CMD ["/app/start.sh"]
