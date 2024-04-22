#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  echo -e "\nWelcome to My Salon, how can I help you?\n"
  #get available serives
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  #if not available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo -e "\n Sorry we are closed for now, Check in Later!"
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID)" $NAME
    done

    #ask for service id
    read SERVICE_ID_SELECTED

    #if not available
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      echo -e "\nEnter a valid number"
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "$SERVICE_ID)" $SERVICE_NAME
      done
      else
      SERVICE_AVAILABILITY=$($PSQL"SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      #if not available
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        echo -e "\nI could not find that service. What would you like today?"
        echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
        do
          echo "$SERVICE_ID)" $SERVICE_NAME
        done
      else
        echo -e "\nWhat's your phone number?"

        #get customer phone
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"

          #get customer name
          read CUSTOMER_NAME

          #insert new Customer
          INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        #get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        SERVICES_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        SERVICES_NAME_FORMATTED=$(echo $SERVICES_NAME | sed 's/ |/"/')
        echo -e "\nWhat time would you like your $SERVICES_NAME_FORMATTED, $CUSTOMER_NAME?"

        #get service time
        read SERVICE_TIME
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

        echo -e "\nI have put you down for a $SERVICES_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}
MAIN_MENU