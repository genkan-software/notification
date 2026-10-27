# --- Build ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# restore layer (cached until a csproj / nuget.config changes)
COPY Genkan.Notification.slnx Directory.Build.props nuget.config ./
COPY src/Genkan.Notification.Domain/Genkan.Notification.Domain.csproj src/Genkan.Notification.Domain/
COPY src/Genkan.Notification.Infrastructure/Genkan.Notification.Infrastructure.csproj src/Genkan.Notification.Infrastructure/
COPY src/Genkan.Notification.Firebase/Genkan.Notification.Firebase.csproj src/Genkan.Notification.Firebase/
COPY src/Genkan.Notification.Application/Genkan.Notification.Application.csproj src/Genkan.Notification.Application/
COPY src/Genkan.Notification.Rabbit/Genkan.Notification.Rabbit.csproj src/Genkan.Notification.Rabbit/
COPY src/Genkan.Notification.Api/Genkan.Notification.Api.csproj src/Genkan.Notification.Api/
# Genkan.Shared comes from GitHub Packages; nuget.config reads the token from GITHUB_PACKAGES_TOKEN.
#   docker build --secret id=github_token,env=GITHUB_PACKAGES_TOKEN .
RUN --mount=type=secret,id=github_token \
    GITHUB_PACKAGES_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || true)" dotnet restore Genkan.Notification.slnx

COPY src/ src/
RUN dotnet publish src/Genkan.Notification.Api -c Release -o /app --no-restore

# --- Runtime ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "Genkan.Notification.Api.dll"]
