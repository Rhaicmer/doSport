# --- Estágio de Build (melhora o desempenho de cache) ---
FROM openjdk:17-jdk-slim AS build # Removido o comentário aqui

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o Maven Wrapper e o POM para o container para baixar as dependências
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Dá permissão de execução ao Maven Wrapper
RUN chmod +x mvnw

# Baixa as dependências do Maven (isso acelera builds futuros se as dependências não mudarem)
RUN ./mvnw dependency:go-offline -B

# Copia o restante do código fonte para o container
COPY src ./src

# Compila e empacota a aplicação
RUN ./mvnw clean package -DskipTests

# --- Estágio de Runtime (imagem final menor) ---
FROM openjdk:17-jre-slim-buster # Usando a tag que corrigimos antes

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o JAR compilado do estágio de build
COPY --from=build /app/target/*.jar app.jar

# Expõe a porta que a aplicação Spring Boot irá escutar
EXPOSE 10000

# Comando para rodar a aplicação quando o container iniciar
ENTRYPOINT ["java", "-jar", "app.jar"]