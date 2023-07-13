#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_game -t -c"

RNG=$(( $RANDOM % 1000 + 1 ))
ATTEMPT=1
GUESS=0

echo Enter your username:
read USERNAME
USERNAME_TEST=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ -z $USERNAME_TEST ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  RES=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
else
  read COUNT BAR BEST <<< $($PSQL "SELECT COUNT(*), MIN(num_of_attempts) FROM games 
                            LEFT JOIN users ON games.user_id = users.user_id WHERE username = '$USERNAME'")
  echo Welcome back, $USERNAME! You have played $COUNT games, and your best game took $BEST guesses.
fi
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $RNG ]]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  elif (( GUESS > RNG ))
  then
    echo "It's lower than that, guess again:"
    (( ATTEMPT++ ))
  elif (( GUESS < RNG ))
  then
    echo "It's higher than that, guess again:"
    (( ATTEMPT++ ))
  else
    echo You guessed it in $ATTEMPT tries. The secret number was $RNG. Nice job!
  fi
done

RES=$($PSQL "INSERT INTO games (user_id, num_of_attempts) VALUES ($USER_ID, $ATTEMPT)")
