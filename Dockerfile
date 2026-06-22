# -------------------------------------------------------------
# ShopEasy Dockerfile - Cloud Hosting & Deployment
# Supports auto-compilation and serving on Apache Tomcat
# -------------------------------------------------------------

# Step 1: Build the Maven application
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Step 2: Deploy packaged WAR inside Apache Tomcat
FROM tomcat:9.0-jdk11-openjdk-slim
WORKDIR /usr/local/tomcat

# Remove default Tomcat apps to serve ShopEasy from the root path (/)
RUN rm -rf webapps/*

# Disable Tomcat's shutdown port to prevent "Invalid shutdown command" warnings from health checks
RUN sed -i 's/port="8005"/port="-1"/g' conf/server.xml


# Copy the build output WAR from the maven stage as ROOT.war
COPY --from=build /app/target/ECommerceApp.war webapps/ROOT.war

# Expose Tomcat default port
EXPOSE 8080

# Start Tomcat Server
CMD ["catalina.sh", "run"]
