echo "Docker ID and Image: $dockerpath"
docker login
docker tag capstone nilay16/capstone:v1
docker push nilay16/capstone:v1