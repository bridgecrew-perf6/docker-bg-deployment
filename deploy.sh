#!/bin/bash

LB="loadbalancer"
BLUE="app-blue"
BLUE_PORT=80
GREEN="app-green"
GREEN_PORT=80
UPSTREAM_URL="http://localhost/dynamic?upstream=zone_for_backends"

setup () {
  docker compose up -d ${BLUE}
  docker compose up -d ${LB}

  while [ "$(curl localhost -o /dev/null -w '%{http_code}\n' -s)" -ne 200 ]
  do
    sleep 1
  done

  docker compose rm -fsv ${GREEN}
}

new_active () {
  ACTIVE=$(docker compose ps --services | grep -v "${LB}" | grep "${BLUE}")

  if [ "${ACTIVE}" == "${BLUE}" ]; then
    echo "${GREEN}"
  else
    echo "${BLUE}"
  fi
}

deployment () {
  NEW_ACTIVE=$1
  NEW_ACTIVE_PORT=$2
  NEW_STANDBY=$3
  NEW_STANDBY_PORT=$4

  docker compose pull "${NEW_ACTIVE}"
  docker compose up -d "${NEW_ACTIVE}"
  NEW_ACTIVE_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${NEW_ACTIVE}")
  NEW_STANDBY_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${NEW_STANDBY}")

  curl -s "${UPSTREAM_URL}&server=${NEW_ACTIVE_IP}:${NEW_ACTIVE_PORT}&up="
  curl -s "${UPSTREAM_URL}&server=${NEW_STANDBY_IP}:${NEW_STANDBY_PORT}&down="
  docker compose rm -fsv "${NEW_STANDBY}"
}


if [ "$(docker compose ps --services | wc -l)" -eq 1 ]; then
  setup
elif [ "$(new_active)" == "${BLUE}" ]; then
  deployment "${BLUE}" "${BLUE_PORT}" "${GREEN}" "${GREEN_PORT}"
else
  deployment "${GREEN}" "${GREEN_PORT}" "${BLUE}" "${BLUE_PORT}"
fi

cat <<EOS
deployment is completed!
===== current upstream =====
$(curl -s "${UPSTREAM_URL}")
===== current service =====
$(docker compose ps)
EOS
