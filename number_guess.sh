#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e '\033[0;35m' 

echo -e "Enter your username:"
read USERNAME

USER_ID_CHECK=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'");

if [[ -z $USER_ID_CHECK ]] 
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID_CHECK")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID_CHECK")

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
##START GAME VVVV

SECRET_NUMBER=$((RANDOM % 1000))
GUESS_COUNTER=1

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'");

echo -e "\nGuess the secret number between 1 and 1000:"

GUESSING_GAME() {
  read PLAYER_GUESS
  if [[ $PLAYER_GUESS =~ ^[0-9]+$ ]] 
  then 
    if [[ $PLAYER_GUESS > $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
      GUESS_COUNTER=$(($GUESS_COUNTER + 1))
      GUESSING_GAME
    elif [[ $PLAYER_GUESS < $SECRET_NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
      GUESS_COUNTER=$(($GUESS_COUNTER + 1))
      GUESSING_GAME
    else 
      echo -e "You guessed it in $GUESS_COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
      DB_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
      
      if [[ -z $GAMES_PLAYED ]]
      then
        INSERT_FIRST_GAME=$($PSQL "UPDATE users SET games_played = 1 WHERE user_id = $USER_ID")
      else
        NEW_GAME_COUNT=$(($GAMES_PLAYED + 1))
        UPDATE_GAME_COUNT=$($PSQL "UPDATE users SET games_played = $NEW_GAME_COUNT WHERE user_id = $USER_ID")
      fi

      if [[ -z $DB_BEST_GAME ]]
      then
        INSERT_FIRST_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNTER WHERE user_id = $USER_ID")
      elif (($DB_BEST_GAME > $GUESS_COUNTER))
      then
          INSERT_NEW_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNTER WHERE user_id = $USER_ID")
      fi
      #reset counter
      GUESS_COUNTER=0
    fi

  else
   echo "That is not an integer, guess again:"
   GUESSING_GAME
  fi
}

GUESSING_GAME
