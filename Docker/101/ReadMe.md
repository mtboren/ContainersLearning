# Some Docker Learning Activities
From the Docker-provided tutorial https://www.docker.com/101-tutorial/

## Takeaways, Highlights, Observations
Covered things like
- tagging local image with repo to which to push
- pushing to container registry & repo
- interactive session / `exec`ing in container
    - interactive: `docker exec -it some_corntainer /bin/bash`
    - execute and return outcome: `docker exec some_corntainer cat /data.txt`
- named volumes
    - inspecting them via `docker volume inspect my-cool-vol`
    - mounting them via `docker run --name my_cool_webapp -dp 3000:3000 --volume my-cool-vol:/etc/todos getting-started`
- bind mounts
    - launching a container with a bind mount of a host-local path (current working dir); example use case:  launch a container to host app with live updates in app when code on local filesystem updated (by watching app src code via nodemon -- called via the `yarn run` call of the `dev` package.json script)
        ```PowerShell
        ## in PowerShell
        docker run -dp 3000:3000 `
            --workdir /app --volume "$($pwd.Path):/app" `
            --name my_cool_webapp `
            node:18-alpine `
            sh -c "yarn install && yarn run dev"
        ```
- using a Docker "network"
    - launch
        ```PowerShell
        ## create the Docker network one time
        docker network create todo-app

        ## launch a container, attaching it to said network, and creating named volume (Docker does so automatically)
        docker run -d `
            --network todo-app --network-alias mysql `
            --volume todo-mysql-data:/var/lib/mysql `
            --env MYSQL_ROOT_PASSWORD=secret `
            --env MYSQL_DATABASE=todos `
            --name my_db `
            mysql:8.0
        ```
- watch/follow container logs: `docker logs --follow my_cool_webapp`
- and, `docker compose` for using a Compose file to define the containers, volumes, etc.
- container stop/removal via PowerShell pipeline, without forcing: `docker stop my_cool_webapp | Foreach-Object {docker rm $_}`
- one take on container layout:
    > In general, each container should do one thing and do it well
