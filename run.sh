#!/bin/bash

set -ex

# =======
# Prepare

mkdir -p workspace

# ===
# Run

run() {
    docker run -it \
    -u $(id -u):$(id -g) \
    -v `pwd`/workspace:/workspace \
    -v `pwd`/scripts:/scripts:ro \
    -v `pwd`/../opencv:/opencv:ro \
    -v `pwd`/../opencv_extra:/opencv_extra:ro \
    ${tag} \
    $@
}

for platform in 22 ; do

tag=opencv-numpy-check-${platform}
docker build --build-arg CPUNUM=12 -t ${tag} -f Dockerfile-${platform} .
# run

run build-numpy v2.0.0rc1 # latest 2.x
run build-numpy v2.1.0.dev0 # 2.x dev
run build-numpy v1.26.4 # latest 1.x
run build-numpy v1.21.5 # same as ubuntu 22

# test with same version
run build-opencv v1.26.4
run build-opencv v2.0.0rc1
run build-opencv v2.1.0.dev0

# 1.x -> 2.x doesn't work
# run build-opencv v1.26.4 v2.0.0rc1
# run build-opencv v1.26.4 v2.1.0.dev0

# 2.x -> 1.x works
run build-opencv v2.0.0rc1 v1.21.5
run build-opencv v2.0.0rc1 v1.26.4
run build-opencv v2.1.0.dev0 v1.26.4
run build-opencv v2.1.0.dev0 v2.0.0rc1

done
