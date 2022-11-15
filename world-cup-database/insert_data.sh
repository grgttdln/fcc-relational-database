#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

echo $($PSQL "TRUNCATE TABLE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  TEAM_WINNER_ID=$($PSQL "SELECT name FROM teams where name='$WINNER'")
  if [[ $WINNER != "winner" ]]
  then
    if [[ -z $TEAM_WINNER_ID ]]
    then
      INSERT_TEAM_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
  fi

  TEAM_OPPONENT_ID=$($PSQL "SELECT name FROM teams where name='$OPPONENT'")
  if [[ $OPPONENT != "opponent" ]]
  then
    if [[ -z $TEAM_OPPONENT_ID ]]
    then
      INSERT_TEAM_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi
  fi

  GAME_ID_WINNER=$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER'")
  GAME_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ -n $GAME_ID_WINNER || $GAME_ID_OPPONENT ]]
  then
    if [[ $YEAR != "year" ]]
    then
      INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $GAME_ID_WINNER, $GAME_ID_OPPONENT)")
      if [[ $INSERT_GAMES == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR, $ROUND, $WINNER_GOALS, $OPPONENT_GOALS, $WINNER, $OPPONENT
      fi
    fi
  fi

done
