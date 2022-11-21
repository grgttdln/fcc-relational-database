#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USER_USERNAME

USER_PLAYED=$($PSQL "SELECT games_played FROM usernames WHERE username='$USER_USERNAME'")

if [[ -z $USER_PLAYED ]] 
then
  USER_ADD=$($PSQL "INSERT INTO usernames(username, games_played) VALUES('$USER_USERNAME', 1)")
  echo Welcome, $USER_USERNAME! It looks like this is your first time here.
else
  USER_BEST=$($PSQL "SELECT best_game FROM usernames WHERE username='$USER_USERNAME'")
  echo Welcome back, $USER_USERNAME! You have played $USER_PLAYED games, and your best game took $USER_BEST guesses.
  
  USER_GAMES_PLAYED=$($PSQL "SELECT games_played FROM usernames WHERE username='$USER_USERNAME'")
  USER_GAME_ADDED=$(( $USER_GAMES_PLAYED + 1 ))
  USER_GAMES_INSERT=$($PSQL "UPDATE usernames SET games_played=$USER_GAME_ADDED WHERE username='$USER_USERNAME'")
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
echo Guess the secret number between 1 and 1000:

GUESS=1
while read USER_GUESS
do 
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    if [[ $USER_GUESS -eq $RANDOM_NUMBER ]]
    then
      break;
    else
      if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
      then
        echo -n "It's lower than that, guess again:"
      else 
        echo -n "It's higher than that, guess again:"
      fi
    fi
  fi
  GUESS=$(( $GUESS + 1 ))
done

echo You guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!

USER_BEST_GAME_BEFORE=$($PSQL "SELECT best_game FROM usernames WHERE username='$USER_USERNAME'")
if [[ -z $USER_BEST_GAME_BEFORE ]]
then
  USER_BEST_GAME_INSERT=$($PSQL "UPDATE usernames SET best_game=$GUESS WHERE username='$USER_USERNAME'")
else
  if [[ $USER_BEST_GAME_BEFORE > $GUESS ]]
  then
    USER_BEST_GAME_INSERT=$($PSQL "UPDATE usernames SET best_game=$GUESS WHERE username='$USER_USERNAME'")
  fi
fi

