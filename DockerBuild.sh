
docker build -t ib_gateway-image .

docker run -d   --name iTraderBot.IB.Gateway \
                --restart always \
                --network iTradeBotNetwork \
                --env-file .env \
                -p 4001:4001 \
                -p 4002:4002 \
                -p 5900:5900 \
                ib_gateway-image

# Using Service
docker service create \
            --name IBGateway-Service \
            --reserve-memory=2GB \
            --replicas 1 \
            --secret iTraderBot_UID \
            --secret iTraderBot_PWD \
            --secret iTraderBot_VNC \
            --env-file .env \
            --publish published=4001,target=4001 \
            --publish published=4002,target=4002 \
            --publish published=5900,target=5900 \
        ib_gateway-image:latest

docker service  create --name redis --secret iTraderBot_VNC redis:alpine


docker container exec $(docker ps --filter name=redis -q) cat /run/secrets/iTraderBot_VNC

docker container ls -f "IMAGE=ib_gateway-image:latest"