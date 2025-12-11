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
- container stop/removal via PowerShell pipeline, without forcing: `docker stop affectionate_tharp | Foreach-Object {docker rm $_}`
