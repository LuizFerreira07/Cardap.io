#!/bin/bash

# Baixa a versão estável do Flutter (download leve e rápido)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Adiciona o Flutter ao PATH
export PATH="$PATH:$PWD/flutter/bin"

# Configura e compila para Web
flutter config --enable-web
flutter pub get
flutter build web --release