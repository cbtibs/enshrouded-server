FROM ghcr.io/cbtibs/base-containers:cd65e06-steamcmd-proton

ENV ENSHROUDED_PATH="/home/steam/enshrouded"
ENV ENSHROUDED_CONFIG="${ENSHROUDED_PATH}/enshrouded_server.json"
ENV STEAM_APP_ID="2278520"  
ENV STEAM_COMPAT_DATA_PATH="${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID}"  

USER root
RUN apt-get update && apt-get install -y procps vim gettext-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER steam

RUN mkdir -p "$ENSHROUDED_PATH" && \
    mkdir -p "${ENSHROUDED_PATH}/savegame" && \
    mkdir -p "${ENSHROUDED_PATH}/logs" && \
    mkdir -p "${STEAMCMD_PATH}/steamapps/compatdata/${STEAM_APP_ID}" && \
    ${STEAMCMD_PATH}/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$ENSHROUDED_PATH" +login anonymous +app_update ${STEAM_APP_ID} validate +quit

COPY --chmod=755 entrypoint.sh /home/steam/entrypoint.sh
COPY enshrouded_server.template.json /home/steam/enshrouded_server.template.json

WORKDIR /home/steam

ENTRYPOINT ["/home/steam/entrypoint.sh"]
