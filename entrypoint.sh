#!/bin/bash
set -a

timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Environment Variable Defaults
: "${SERVER_NAME:=Enshrouded Server}"
: "${SAVE_DIRECTORY:=./savegame}"
: "${LOG_DIRECTORY:=./logs}"
: "${SERVER_IP:=0.0.0.0}"
: "${QUERY_PORT:=15637}"
: "${SLOT_COUNT:=16}"
: "${GAME_SETTINGS_PRESET:=Default}"
: "${PLAYER_HEALTH_FACTOR:=1}"
: "${PLAYER_MANA_FACTOR:=1}"
: "${PLAYER_STAMINA_FACTOR:=1}"
: "${PLAYER_BODY_HEAT_FACTOR:=1}"
: "${ENABLE_DURABILITY:=true}"
: "${ENABLE_STARVING_DEBUFF:=false}"
: "${FOOD_BUFF_DURATION_FACTOR:=1}"
: "${FROM_HUNGER_TO_STARVING:=600000000000}"
: "${SHROUD_TIME_FACTOR:=1}"
: "${TOMBSTONE_MODE:=AddBackpackMaterials}"
: "${ENABLE_GLIDER_TURBULENCES:=true}"
: "${WEATHER_FREQUENCY:=Normal}"
: "${MINING_DAMAGE_FACTOR:=1}"
: "${PLANT_GROWTH_SPEED_FACTOR:=1}"
: "${RESOURCE_DROP_STACK_AMOUNT_FACTOR:=1}"
: "${FACTORY_PRODUCTION_SPEED_FACTOR:=1}"
: "${PERK_UPGRADE_RECYCLING_FACTOR:=0.5}"
: "${PERK_COST_FACTOR:=1}"
: "${EXPERIENCE_COMBAT_FACTOR:=1}"
: "${EXPERIENCE_MINING_FACTOR:=1}"
: "${EXPERIENCE_EXPLORATION_QUESTS_FACTOR:=1}"
: "${RANDOM_SPAWNER_AMOUNT:=Normal}"
: "${AGGRO_POOL_AMOUNT:=Normal}"
: "${ENEMY_DAMAGE_FACTOR:=1}"
: "${ENEMY_HEALTH_FACTOR:=1}"
: "${ENEMY_STAMINA_FACTOR:=1}"
: "${ENEMY_PERCEPTION_RANGE_FACTOR:=1}"
: "${BOSS_DAMAGE_FACTOR:=1}"
: "${BOSS_HEALTH_FACTOR:=1}"
: "${THREAT_BONUS:=1}"
: "${PACIFY_ALL_ENEMIES:=false}"
: "${TAMING_STARTLE_REPERCUSSION:=LoseSomeProgress}"
: "${DAY_TIME_DURATION:=1800000000000}"
: "${NIGHT_TIME_DURATION:=720000000000}"
: "${ADMIN_PASSWORD:=adminPass}"
: "${USER_PASSWORD:=userPass}"

# Generate Configuration File
envsubst < /home/steam/enshrouded_server.template.json > "${ENSHROUDED_PATH}/enshrouded_server.json"
set +a
echo "$(timestamp) INFO: Configuration file generated at ${ENSHROUDED_PATH}/enshrouded_server.json"

# Ensure Log Directory and Symlink
mkdir -p "${ENSHROUDED_PATH}/logs"
if ! [ -f "${ENSHROUDED_PATH}/logs/enshrouded_server.log" ]; then
    touch "${ENSHROUDED_PATH}/logs/enshrouded_server.log"
fi

# Link logfile to stdout (using the stdout of PID 1)
ln -sf /proc/1/fd/1 "${ENSHROUDED_PATH}/logs/enshrouded_server.log"

# Launch the Server Process
echo "$(timestamp) INFO: Starting Enshrouded server using Proton..."
"$PROTON_PATH/proton" run "${ENSHROUDED_PATH}/enshrouded_server.exe" &

timeout=0
while [ $timeout -lt 11 ]; do
    if ps -e | grep "enshrouded_serv"; then
        enshrouded_pid=$(ps -e | grep "enshrouded_serv" | awk '{print $1}')
        break
    elif [ $timeout -eq 10 ]; then
        echo "$(timestamp) ERROR: Timed out waiting for enshrouded_server.exe to be running"
        exit 1
    fi
    sleep 6
    ((timeout++))
    echo "$(timestamp) INFO: Waiting for enshrouded_server.exe to be running"
done

# Keep server open until terminate
tail --pid=$enshrouded_pid -f /dev/null &
wait

if ps -e | grep "enshrouded_serv"; then
    tail --pid=$enshrouded_pid -f /dev/null
fi

echo "$(timestamp) INFO: Shutdown complete."
exit 0
