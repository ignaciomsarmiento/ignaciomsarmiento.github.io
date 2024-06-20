#!/bin/bash

# Crear directorios de nivel superior
mkdir -p 01_build 02_analysis 03_document

# Crear subdirectorios dentro de build y analysis
for dir in 01_build 02_analysis
do
  mkdir -p ./$dir/01_input
  mkdir -p ./$dir/02_scripts
  mkdir -p ./$dir/03_output
  mkdir -p ./$dir/04_temp
done

# Navegar al directorio 02_analysis/03_output y crear subdirectorios
cd 02_analysis/03_output
mkdir -p Figures Tables

# Volver al directorio principal
cd ../..

# Crear un archivo README.txt en blanco
touch README.txt

echo "¡Carpetas creadas exitosamente!"