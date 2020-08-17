#/usr/bin/env sh

#docker run --rm --name nginx-repo -v $PWD/pub:/usr/share/nginx/html:ro -d -p 8000:80 nginx:1.17-alpine
docker restart nginx-repo
docker logs -f nginx-repo

