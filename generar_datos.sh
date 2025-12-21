#!/bin/bash

# Crear y activar entorno virtual
VENV_DIR="$PROJECT_DIR/venv"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Instalar dependencias
pip install --upgrade pip
pip install pandas numpy geopy requests

# Trap para limpiar el venv al salir
trap "rm -rf '$VENV_DIR'" EXIT

# Script para ejecutar los scripts de procesamiento de datos del proyecto

set -e  # Salir si hay error

echo "========================================="
echo "Iniciando procesamiento de datos"
echo "========================================="

# Directorio base del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo "Directorio del proyecto: $PROJECT_DIR"
echo ""

# Ejecutar scripts de luchadores
echo "1. Procesando datos de luchadores"
python3 "$PROJECT_DIR/data/luchadores/cocina_luchadores.py"
echo ""

echo "2. Generando estilos de luchadores"
python3 "$PROJECT_DIR/data/luchadores/cocina_estilos.py"
echo ""

# Ejecutar scripts de luchas
echo "3. Procesando datos de luchas"
python3 "$PROJECT_DIR/data/luchas/cocina_luchas.py"
echo ""

echo "4. Geocodificando coordenadas de eventos"
python3 "$PROJECT_DIR/data/luchas/cocina_coordenadas.py"
echo ""

echo "========================================="
echo "¡Proceso completado con éxito!"
echo "========================================="
