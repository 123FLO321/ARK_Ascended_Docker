#!/bin/bash
ASA_APPID=2430930

set -ex

# Create steam directory and set variables
mkdir -p /home/arkuser/.steam/steam/steamapps/compatdata/${ASA_APPID}
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/arkuser/.steam/steam"
export STEAM_COMPAT_DATA_PATH="/home/arkuser/.steam/steam/steamapps/compatdata/${ASA_APPID}"

# Install ASA server
/opt/steamcmd/steamcmd.sh +force_install_dir /opt/arkserver +login anonymous +app_update ${ASA_APPID} validate +quit

# Server main options
cmd="${SERVER_MAP}?listen?SessionName=\"${SESSION_NAME}\"?Port=${SERVER_PORT}"
if [ -n ${MAX_PLAYERS} ]; then
    cmd="${cmd}?MaxPlayers=${MAX_PLAYERS}"
fi

if [ -n ${SERVER_PASSWORD} ]; then
    cmd="${cmd}?ServerPassword=${SERVER_PASSWORD}"
fi

if [ -n ${ARK_ADMIN_PASSWORD} ]; then
    cmd="${cmd}?ServerAdminPassword=\"${ARK_ADMIN_PASSWORD}\""
fi

if [ -n ${RCON_PORT} ]; then
    cmd="${cmd}?RCONEnabled=True?RCONPort=${RCON_PORT}"
fi

cmd="${cmd}${ARK_EXTRA_OPTS}"

# Server dash options
ark_flags="-log"
if [ -n ${DISABLE_BATTLEYE} ]; then 
    ark_flags="${ark_flags} -NoBattlEye"
else 
    ark_flags="${ark_flags} -BattlEye"
fi

if [ -n ${MAX_PLAYERS} ]; then 
    ark_flags="${ark_flags} -WinLiveMaxPlayers=${MAX_PLAYERS}"
fi

ark_flags="${ark_flags} ${ARK_EXTRA_DASH_OPTS}"

# Run server and show logs
mkdir -p /opt/arkserver/ShooterGame/Saved/Logs && touch /opt/arkserver/ShooterGame/Saved/Logs/ShooterGame.log

proton run /opt/arkserver/ShooterGame/Binaries/Win64/ArkAscendedServer.exe ${cmd} ${ark_flags} &
ARK_PID=$!
tail -c0 -F /opt/arkserver/ShooterGame/Saved/Logs/ShooterGame.log --pid=$ARK_PID