#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Si no se proporciona argumento
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Validación de input
if [[ ! $1 =~ ^[0-9A-Za-z]+$ ]]; then
  echo "Invalid input. Please use atomic number, symbol or name."
  exit 1
fi

# Función para formatear números
format_number() {
  local num=$1
  if [[ $num == *.* ]]; then
    num=$(echo "$num" | sed 's/\.0*$//;s/\(\.\?[0-9]*[1-9]\)0*$/\1/')
  fi
  echo "$num"
}

# Buscar el elemento
if [[ $1 =~ ^[0-9]+$ ]]; then
  # Búsqueda por número atómico
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                       FROM elements e 
                       JOIN properties p ON e.atomic_number = p.atomic_number 
                       JOIN types t ON p.type_id = t.type_id 
                       WHERE e.atomic_number = $1")
else
  # Búsqueda por símbolo o nombre (case insensitive)
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                       FROM elements e 
                       JOIN properties p ON e.atomic_number = p.atomic_number 
                       JOIN types t ON p.type_id = t.type_id 
                       WHERE e.symbol ILIKE '$1' OR e.name ILIKE '$1'")
fi

# Si no se encontró el elemento
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parsear la información
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_INFO"

# Formatear los números
ATOMIC_MASS=$(format_number "$ATOMIC_MASS")
MELTING_POINT=$(format_number "$MELTING_POINT")
BOILING_POINT=$(format_number "$BOILING_POINT")

# Mostrar la información
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."