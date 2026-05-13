FROM eclipse-temurin:23-jdk AS build
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

COPY common/build.gradle.kts common/
COPY product-service/build.gradle.kts product-service/
COPY product/build.gradle.kts product/

RUN ./gradlew dependencies --no-daemon

COPY . .

RUN ./gradlew :product-service:bootJar -x test --no-daemon

FROM eclipse-temurin:23-jre
WORKDIR /app

RUN useradd -ms /bin/bash springuser
USER springuser

COPY --from=build /app/product-service/build/libs/product-service.jar app.jar

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=staging", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "app.jar"]

EXPOSE 8080