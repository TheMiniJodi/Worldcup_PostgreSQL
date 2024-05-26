#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# year,round,winner,opponent,winner_goals,opponent_goals
echo $($PSQL "TRUNCATE teams, games")

sed 1d games.csv | while IFS="," read YEAR ROUND WINNER_NAME OPPONENT_NAME WINNER_GOALS OPPONENT_GOALS
do

  # Insert into teams table
  GET_TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER_NAME' ")
  GET_TEAM_NAME2=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT_NAME' ")
  if [[ -z $GET_TEAM_NAME ]]
  then
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER_NAME')")
    if [[ $INSERT_TEAM == "INSERT 0 1" ]]
    then
      echo team $WINNER_NAME has been added
    fi
  fi
  if [[ -z $GET_TEAM_NAME2 ]]
  then
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT_NAME')")
    if [[ $INSERT_TEAM == "INSERT 0 1" ]]
    then
      echo team $OPPONENT_NAME has been added
    fi
  fi


  # Get team id
  GET_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER_NAME'" ) 
  GET_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT_NAME'" ) 

  # Insert match
  INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $GET_WINNER_ID, $GET_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)" )
  if [[ $INSERT_GAMES == "INSERT 0 1" ]]
  then
    echo match successfully added
  fi
done