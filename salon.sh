#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo $($PSQL "TRUNCATE services, appointments;")

# reset sequence
RESET_SEQ=$($PSQL "ALTER SEQUENCE services_service_id_seq RESTART WITH 1;")
# insert services
INSERT_CUT=$($PSQL "INSERT INTO services(name) VALUES('cut');")
INSERT_COLOR=$($PSQL "INSERT INTO services(name) VALUES('color');")
INSERT_PERM=$($PSQL "INSERT INTO services(name) VALUES('perm');")
INSERT_STYLE=$($PSQL "INSERT INTO services(name) VALUES('style');")
INSERT_TRIM=$($PSQL "INSERT INTO services(name) VALUES('trim');")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE=$($PSQL "SELECT service_id,name FROM services;")

  echo "$SERVICE" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE "cut" ;;
    2) SERVICE "color" ;;
    3) SERVICE "perm" ;;
    4) SERVICE "style" ;;
    5) SERVICE "trim" ;;
    *) MAIN_MENU "\nI could not find that service. What would you like today?\n" ;;
  esac

}

SERVICE() {

  # get customer info
  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?\n"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi

  # ask appointment time
  echo -e "\nWhat time would you like your $1,$CUSTOMER_NAME?\n"
  read SERVICE_TIME

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  # get service id
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name ='$1';")

  # insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi

}

MAIN_MENU