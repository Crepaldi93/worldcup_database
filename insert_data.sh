#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear all data from the "games" and "teams" tables
echo $($PSQL "TRUNCATE TABLE games, teams")

# Restart sequences
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")

# Read the "games.csv" file and insert data into the "teams" table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Exclude header from the loop
  if [[ $WINNER != "winner" ]]
  then
    # Get winner id from the "teams" table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert team into the "teams" table
      WINNER_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $WINNER_ID_RESULT == "INSERT 0 1" ]]
      then
        echo "$WINNER Inserted into the 'teams' table"
      fi
    fi
  fi

  # Exclude header from the loop
  if [[ $OPPONENT != "opponent" ]]
  then
    # Get opponent id from the "teams" table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert team into the "teams" table
      OPPONENT_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $OPPONENT_ID_RESULT == "INSERT 0 1" ]]
      then
        echo "$OPPONENT Inserted into the 'teams' table"
      fi
    fi
  fi
done

# Read the "games.csv" file and insert data into the "games" table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $YEAR != "year" ]]
  then
    # Get id for the winning team
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Get id for the losing team
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert data into the "games" table
    INSERT_DATA_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_DATA_RESULT == "INSERT 0 1" ]]
    then
      echo "New Game Inserted"
    fi
  fi
done
