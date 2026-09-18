#!/bin/bash

# Baixa a versão estável do Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Adiciona o Flutter ao PATH do Vercel
export PATH="$PATH:`pwd`/flutter/bin"

# Habilita o suporte web e compila o projeto
flutter config --enable-web
flutter pub get
flutter build web --release