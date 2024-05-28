#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
# Truncate the tables
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

# Read the games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Insert teams if they don't exist
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          echo "Inserted into teams, $TEAM"
        fi
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      fi
    done

    # Get the IDs of the teams
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR $ROUND: $WINNER vs $OPPONENT"
    fi
  fi
done
