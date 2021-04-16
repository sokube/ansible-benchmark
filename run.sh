#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Please modify the number of Hosts !
NOF_HOSTS=8

NETWORK_NAME="ansible.lab"
WORKSPACE="${BASEDIR}/lab"

HOSTPORT_BASE=${HOSTPORT_BASE:-42726}

DOCKER_IMAGETAG=${DOCKER_IMAGETAG:-latest}
DOCKER_HOST_IMAGE="centos-7-ansible-docker-host:${DOCKER_IMAGETAG}"
LAB_IMAGE="ansible-controller:${DOCKER_IMAGETAG}"

function help() {
    echo -ne "-h, --help              prints this help message
-r, --remove            remove created containers and network
-t, --test              run ansible version
"
}
function doesNetworkExist() {
    return $(docker network inspect $1 >/dev/null 2>&1)
}

function removeNetworkIfExists() {
    doesNetworkExist $1 && echo "removing network $1" && docker network rm $1 >/dev/null
}

function doesContainerExist() {
    return $(docker inspect $1 >/dev/null 2>&1)
}

function isContainerRunning() {
    [[ "$(docker inspect -f "{{.State.Running}}" $1 2>/dev/null)" == "true" ]]
}

function killContainerIfExists() {
    doesContainerExist $1 && echo "killing/removing container $1" && { docker kill $1 >/dev/null 2>&1; docker rm $1 >/dev/null 2>&1; };
}

function runHostContainer() {
    local name=$1
    local image=$2
    local port1=$(($HOSTPORT_BASE + $3))
    echo "starting container ${name}: mapping hostport $port1 -> container port 80"
    if doesContainerExist ${name}; then
        docker start "${name}" > /dev/null
    else
        docker run --privileged -d -p $port1:80 --net ${NETWORK_NAME} --name="${name}" "${image}" >/dev/null
    fi
    if [ $? -ne 0 ]; then
        echo "Could not start host container. Exiting!"
        exit 1
    fi
}

function runControllerContainer() {
    local entrypoint=""
    local args=""
    if [ -n "${TEST}" ]; then
        entrypoint="--entrypoint ansible"
        args="--version"
    fi
    killContainerIfExists ansible.controller > /dev/null
    echo "starting container ansible.controller"
    docker run --privileged -it -v "${WORKSPACE}":/root/lab:Z --net ${NETWORK_NAME} \
      --env HOSTPORT_BASE=$HOSTPORT_BASE \
      ${entrypoint} --name="ansible.controller" "${LAB_IMAGE}" ${args}
    return $?
}

function remove () {
    for ((i = 0; i < $NOF_HOSTS; i++)); do
       killContainerIfExists node$i
    done
    removeNetworkIfExists ${NETWORK_NAME}
}

function setupFiles() {
    local inventory="${WORKSPACE}/inventory"
    rm -f "${inventory}"
    echo "[nodes]" > "${inventory}"
    for ((i = 0; i < $NOF_HOSTS; i++)); do
        ip=$(docker network inspect --format="{{range \$id, \$container := .Containers}}{{if eq \$container.Name \"node$i\"}}{{\$container.IPv4Address}} {{end}}{{end}}" ${NETWORK_NAME} | cut -d/ -f1)
        echo "node$i ansible_host=$ip ansible_user=root" >> "${inventory}"
    done
    local config="${WORKSPACE}/ansible.cfg"
    rm -f "${config}"
    cat << EOF > ${config}
[defaults]
host_key_checking = False
inventory = ./inventory
# Logging
callback_whitelist = profile_tasks
EOF
}

function init () {
    mkdir -p "${WORKSPACE}"
    doesNetworkExist "${NETWORK_NAME}" || { echo "creating network ${NETWORK_NAME}" && docker network create "${NETWORK_NAME}" >/dev/null; }
    for ((i = 0; i < $NOF_HOSTS; i++)); do
       isContainerRunning node$i || runHostContainer node$i ${DOCKER_HOST_IMAGE} $i
    done
    setupFiles
    runControllerContainer
    exit $?
}

###
MODE="init"
TEST=""
for i in "$@"; do
case $i in
    -r|--remove)
    MODE="remove"
    shift # past argument=value
    ;;
    -t|--test)
    TEST="yes"
    shift # past argument=value
    ;;
    -h|--help)
    help
    exit 0
    shift # past argument=value
    ;;
    *)
    echo "Unknow argument ${i#*=}"
    exit 1
esac
done

if [ "${MODE}" == "remove" ]; then
    remove
elif [ "${MODE}" == "init" ]; then
    init
fi
exit 0
