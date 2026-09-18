#!/bin/bash

# Evita bloqueios interativos em ambientes CI/CD
export BOT=true

# Clona o Flutter para fora do diretório do projeto (/tmp)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter

# Adiciona o Flutter ao PATH
export PATH="$PATH:/tmp/flutter/bin"

# Define o diretório do Flutter como seguro no Git
git config --global --add safe.directory /tmp/flutter

# Configura e executa a compilação Web
flutter config --no-analytics
flutter config --enable-web
flutter pub get
flutter build web --release
