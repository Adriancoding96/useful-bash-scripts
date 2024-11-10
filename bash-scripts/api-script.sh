#!/bin/bash

#                ____________________________________________________
#               /                                                    \
#              |    _____________________________________________     |
#              |   |                                             |    |
#              |   |  Author: Adrian Nilsson                     |    |
#              |   |                                             |    |
#              |   |  Description: Script written in bash to     |    |
#              |   |  simplify sending API requests with curl    |    |
#              |   |  in the terminal                            |    |
#              |   |                                             |    |
#              |   |                                             |    |
#              |   |  >api-send                                  |    |
#              |   |                                             |    |
#              |   |                                             |    |
#              |   |                                             |    |
#              |   |                                             |    |
#              |   |_____________________________________________|    |
#              |                                                      |
#               \_____________________________________________________/
#                      \_______________________________________/
#                   _______________________________________________
#                _-'    .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.  --- `-_
#             _-'.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--.  .-.-.`-_
#          _-'.-.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-`__`. .-.-.-.`-_
#       _-'.-.-.-.-. .-----.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-----. .-.-.-.-.`-_
#    _-'.-.-.-.-.-. .---.-. .-----------------------------. .-.---. .---.-.-.-.`-_
#   :-----------------------------------------------------------------------------:
#   `---._.-----------------------------------------------------------------._.---'

URL="null"
ENDPOINT="null"
PATH_VARIABLE="null"
TYPE="null"
BODY="null"
TOKEN="null"
EMAIL="null"
PASSWORD="null"

function api-cred() {
  if [ $# -ne 2 ]; then
    echo "Usage: api-cred <email> <password>"
    return 1
  fi
  
  EMAIL="$1"
  PASSWORD="$2"
  echo "Credentials set"
}

function api-user() {
  if [ "$EMAIL" == "null" ] || [ "$PASSWORD" == "null" ]; then 
    echo "Error: Email and password must be set using api-cred before calling api-user"
    return 1
  fi


  SIGNUP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{
          "name": "Terminal User",
          "email": "$EMAIL",
          "password": "$PASSWORD"
        }' \
    http://localhost:8080/signup)

  if [ "$SIGNUP_RESPONSE" -ne 200 ] && [ "$SIGNUP_RESPONSE" -ne 201 ]; then
      return 1
  fi

  echo "Signup successful"
}

function api-auth() {
  if [ "$EMAIL" == "null" ] || [ "$PASSWORD" == "null" ]; then
    echo: "Error: Email and password must be set using api-cred before calling api-auth"
    return 1
  fi

  LOGIN_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{
          "email": "$EMAIL",
          "password": "$PASSWORD"
        }' \
    http://localhost:8080/login)

    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')

    if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
      echo "Authentication failed. Token not present" 
      exit 1
    fi
}

function api-url() {
  if [ $# -ne 1 ]; then
    echo "Usage: api-url <url>"
  fi

  URL="$1"
  echo "URL set"
}

function api-endpoint() {
  if [ $# -ne 1 ]; then
    echo "Usage: api-endpoint <endpoint>"
    return 1
  fi

  ENDPOINT="$1"
  echo "Endpoint set"
}

function api-path() {
  if [ $# -ne 1 ]; then
    echo "Usage: api-path <path variable>"
  fi

  PATH_VARIABLE="$1"
  echo "Path variable set"
}

function api-request() {
  if [ $# -ne 1 ]; then
    echo "Usage: api-request <type>"
    return 1
  fi

  TYPE="$(echo "$1" | tr '[:lower:]' '[:upper:]')" #Ensures all letters are uppercase

  case "$TYPE" in
    GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)
      echo "Request type set"
      return 0
      ;;
    *)
      echo "$TYPE not valid, please set to one of the following: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS"
      ;;
  esac
}

function api-body() {
  if [ $# -ne 1 ]; then
    echo "Usage: api-body <body>"
    return 1
  fi
  BODY="$1"
  echo "Request body set"
}

function api-send() {
  if [ "$ENDPOINT" == "null" ] || [ "$TYPE" == "null" ]; then
    echo "Error: Endpoint and type must be send before sending a request"
    return 1
  fi

  if [ "$TOKEN" == "null" ]; then
    echo "Error: Token not found. Authenticate using api-auth before sending requests"
    return 1
  fi

  HTTP_METHOD="$TYPE"

  if [ "$PATH_VARIABLE" != "null" ]; then
    FULL_URL="$URL/$ENDPOINT/$PATH_VARIABLE"
  else
    FULL_URL="$URL/$ENDPOINT"
  fi

  HEADERS=(
    -H "Content-Type: application/json"
    -H "Authorization: Bearer $TOKEN"
    )

    if [ "$BODY" != "null" ]; then
      DATA=(-d "$BODY")
    else
      DATA=()
    fi

    RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -X "$TYPE" "${HEADERS[@]}" "${DATA[@]}" "$FULL_URL")
    HTTP_STATUS=$(echo $RESPONSE | tail -n1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$id')

    if [ "$RESPONSE" -ne 200 ] && [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
        echo "API request failed with status code $RESPONSE"
        echo "Response Body: $RESPONSE_BODY"
        return 1
    fi

    echo "API request successful. Status code: $RESPONSE"
    if [ "$type" == "GET" ]; then 
      echo "Response JSON:"
      echo "$RESPONSE_BODY"
    fi

    BODY="null"
    PATH_VARIABLE="null"
}

function api-reset() {
  URL="null"
  ENDPOINT="null"
  PATH_VARIABLE="null"
  TYPE="null"
  BODY="null"
  TOKEN="null"
  EMAIL="null"
  PASSWORD="null"
  echo "All API variables have been reset."
}

function api() {
    echo "Available API Commands:"
    echo "  api-cred <email> <password>    : Set the API credentials"
    echo "  api-user                       : Create a new user with the set credentials"
    echo "  api-auth                       : Authenticate with the API and retrieve a token"
    echo "  api-url <URL>                  : Set the API URL for the request"
    echo "  api-endpoint <endpoint>        : Set the API endpoint for the request"
    echo "  api-path <path variable>       : (Optional) Set the path variable for the request (id for example)"
    echo "  api-request <type>             : Set the HTTP request type (for example, GET, POST)"
    echo "  api-body '<json_body>'         : (Optional) Set the JSON body for the request"
    echo "  api-send                       : Send the configured API request"
    echo "  api-reset                      : Resets all API variables to default"
    echo ""
    echo "Usage Example:"
    echo "  api-cred user@example.com mypassword"
    echo "  api-user"
    echo "  api-auth"
    echo "  api-url http://localhost:8080"
    echo "  api-endpoint entity"
    echo "  api-request POST"
    echo "  api-body '{\"key\": \"value\"}'"
    echo "  api-send"
}
