#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
else
    # Intentar detectar si el input es numérico
    if [[ $1 =~ ^[0-9]+$ ]]; then
        CONDITION="atomic_number = $1"
    else
        CONDITION="symbol = '$1' OR name = '$1'"
    fi

    ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                    FROM elements e 
                    JOIN properties p USING(atomic_number) 
                    JOIN types t USING(type_id) 
                    WHERE $CONDITION")

    if [[ -z $ELEMENT ]]; then
        echo "I could not find that element in the database."
    else
        echo "$ELEMENT" | while IFS="|" read num name symbol type mass melt boil; do
            echo "The element with atomic number $num is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melt celsius and a boiling point of $boil celsius."
        done
    fi
fi

# Input validation
if [[ ! $1 =~ ^[0-9A-Za-z]+$ ]]; then
  echo 'Invalid input. Please use atomic number, symbol or name.'
  exit 1
fi
