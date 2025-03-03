# Use the existing IB Gateway image as the base
FROM ghcr.io/gnzsnz/ib-gateway:10.30.1t

# Modify the run.sh script to include the gatewayparam logic before calling ibcstart.sh
RUN sed -i '/"${IBC_PATH}\/scripts\/ibcstart.sh" "${TWS_MAJOR_VRSN}" -g/ i \
    gatewayparam=""\n\
    if [ -z "${TWS_OR_GATEWAY}" ]; then\n\
        gatewayparam="-g"\n\
    elif [ "${TWS_OR_GATEWAY}" = "gateway" ]; then\n\
        gatewayparam="-g"\n\
    fi\n' /home/ibgateway/scripts/run.sh && \
    # Ensure the $gatewayparam variable is passed when calling ibcstart.sh
    sed -i 's|"${IBC_PATH}/scripts/ibcstart.sh" "${TWS_MAJOR_VRSN}" -g|${IBC_PATH}/scripts/ibcstart.sh "${TWS_MAJOR_VRSN}" $gatewayparam|' /home/ibgateway/scripts/run.sh


# Switch to root user to install packages
USER root


# Install necessary packages (including git and ca-certificates)
RUN apt-get update -y && \
    apt-get install --no-install-recommends --yes \
    curl \
    ca-certificates \
    git \
    python3 \
    python3-pip \
    netcat-openbsd 

# Setup noVNC for browser VNC access
RUN git clone --depth 1 https://github.com/novnc/noVNC.git && \
    chmod +x ./noVNC/utils/novnc_proxy && \
    git clone --depth 1 https://github.com/novnc/websockify.git ./noVNC/utils/websockify

# Override default noVNC file listing
COPY index.html /noVNC

CMD /bin/bash -c " \
    # Start the IBC and related services\n\
    /home/ibgateway/scripts/run.sh & \
    # Wait for the VNC server to be ready\n\
    until nc -z localhost 5900; do echo 'Waiting for VNC...'; sleep 2; done; \
    # Start the noVNC proxy\n\
    ./noVNC/utils/novnc_proxy --vnc localhost:5900 --listen ${NOVNC_SERVER_PORT} & \
    tail -f /dev/null"