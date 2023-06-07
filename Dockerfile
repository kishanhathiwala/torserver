#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY ["TorServer/TorServer.csproj", "TorServer/"]
RUN dotnet restore "TorServer/TorServer.csproj"

COPY . .
WORKDIR "/src/TorServer"
RUN dotnet build "TorServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TorServer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

RUN apt update && apt upgrade -y && apt install tor -y
COPY torrc /etc/tor/torrc
RUN sed -i -e 's/\r$//' /etc/tor/torrc


EXPOSE 80
EXPOSE 443
EXPOSE 9050

ENTRYPOINT ["dotnet", "TorServer.dll"]