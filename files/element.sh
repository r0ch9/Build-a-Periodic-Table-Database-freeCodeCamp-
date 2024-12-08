#!/bin/bash

# Script to get the information of an element from the periodic table DB

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to query the database
query_element() {
  local input=$1

  $PSQL "
  SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, 
         p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE e.atomic_number::TEXT = '$input'
     OR LOWER(e.symbol) = LOWER('$input')
     OR LOWER(e.name) = LOWER('$input');
  "
}

# Check if argument is provided
if [ $# -eq 0 ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Get the query result
result=$(query_element "$1")

# Check if result is empty
if [ -z "$result" ]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Read the result into variables
IFS='|' read -r atomic_number symbol name type atomic_mass melting_point boiling_point <<< "$result"

# Trim whitespace
atomic_number=$(echo $atomic_number | xargs)
symbol=$(echo $symbol | xargs)
name=$(echo $name | xargs)
type=$(echo $type | xargs)
atomic_mass=$(echo $atomic_mass | xargs)
melting_point=$(echo $melting_point | xargs)
boiling_point=$(echo $boiling_point | xargs)

# Output the formatted information
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."