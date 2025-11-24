#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Buscar ID del usuario
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# Si el usuario no existe
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insertar nuevo usuario
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  # Obtener el ID recién creado
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  # Si existe, obtener estadísticas
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generar número secreto (1-1000)
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

# Bucle del juego
while true
do
  read GUESS

  # Validar si es entero
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    ((GUESS_COUNT++))

    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      # Adivinó
      break
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

# Mensaje final
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# Actualizar estadísticas
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")

CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")

# Si no tiene mejor juego (es nuevo) o si el actual es mejor (menor número)
if [[ -z $CURRENT_BEST || $GUESS_COUNT -lt $CURRENT_BEST ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE user_id = $USER_ID")
fi
# v1.1
