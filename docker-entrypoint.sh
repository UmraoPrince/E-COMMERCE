#!/bin/sh
set -e

# If PORT is supplied by the platform (e.g., Railway), update Tomcat connector port
if [ -n "$PORT" ]; then
  echo "Setting Tomcat connector port to $PORT"
  # Replace common occurrences of port="8080" with the runtime PORT
  sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml || true
fi

# Convert DATABASE_URL (platform provided) to SPRING_DATASOURCE_* if needed
# Expected DATABASE_URL formats: postgres://user:pass@host:port/dbname or mysql://...
if [ -n "$DATABASE_URL" ] && [ -z "$SPRING_DATASOURCE_URL" ]; then
  echo "Parsing DATABASE_URL into SPRING_DATASOURCE_* variables"
  proto="$(echo $DATABASE_URL | awk -F: '{print $1}')"
  url_no_proto="${DATABASE_URL#*://}"
  userpass="$(echo $url_no_proto | cut -d@ -f1)"
  hostpart="$(echo $url_no_proto | cut -d@ -f2)"
  username="$(echo $userpass | cut -d: -f1)"
  password="$(echo $userpass | cut -d: -f2)"
  hostport="$(echo $hostpart | cut -d/ -f1)"
  dbname="$(echo $hostpart | cut -d/ -f2)"
  host="$(echo $hostport | cut -d: -f1)"
  port="$(echo $hostport | cut -d: -f2)"

  if [ "$proto" = "postgres" ] || [ "$proto" = "postgresql" ]; then
    export SPRING_DATASOURCE_URL="jdbc:postgresql://${host}:${port:-5432}/${dbname}"
    export DB_DRIVER="org.postgresql.Driver"
    export DB_URL="jdbc:postgresql://${host}:${port:-5432}/${dbname}"
  elif [ "$proto" = "mysql" ]; then
    export SPRING_DATASOURCE_URL="jdbc:mysql://${host}:${port:-3306}/${dbname}"
    export DB_DRIVER="com.mysql.cj.jdbc.Driver"
    export DB_URL="jdbc:mysql://${host}:${port:-3306}/${dbname}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
  fi

  export SPRING_DATASOURCE_USERNAME="$username"
  export SPRING_DATASOURCE_PASSWORD="$password"
  export DB_USERNAME="$username"
  export DB_PASSWORD="$password"
  echo "SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}"
  echo "DB_URL=${DB_URL}"
fi

# Ensure container JVM doesn't attempt container/cgroup metrics that can NPE on some hosts
# Workaround: disable container support in the JVM which prevents cgroup probing.
# This avoids NullPointerException seen in jdk.internal.platform.cgroupv2.CgroupV2Subsystem
if [ -z "$CATALINA_OPTS" ]; then
  export CATALINA_OPTS="-XX:-UseContainerSupport"
else
  export CATALINA_OPTS="$CATALINA_OPTS -XX:-UseContainerSupport"
fi

# Allow passing additional JVM options via CATALINA_OPTS
if [ -n "$CATALINA_OPTS" ]; then
  export JAVA_OPTS="$CATALINA_OPTS $JAVA_OPTS"
fi

# Exec Tomcat
exec catalina.sh run
