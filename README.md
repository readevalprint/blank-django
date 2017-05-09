## Setup

### Dependencies

- git
- [docker-compose](https://docs.docker.com/compose/)

### Installation

```
$ git clone
$ cd site-database

$ docker-compose build
$ docker-compose run proj setupdb
$ docker-compose run proj test_coverage
```

### Setup

The only thing that you need now is a superuser!
```
docker-compose run proj manage createsuperuser
```


## Usage

This will start the proj server 0.0.0.0:8000


```
$ docker-compose up
```

## Development

All development should be tested within the container, but can be developed on the host. Read the `docker-compose.yml` file to see how it's mounted.
```
$ docker-compose run proj bash
root@localhost:/#
```

## kubernetes

requires [envsub](https://linux.die.net/man/1/envsubst) and [minikube](https://kubernetes.io/docs/getting-started-guides/minikube/)

```
$ cd config
$ openssl genrsa 1024 > proj.key
$ openssl req -new -x509 -nodes -sha1 -days 365 -key proj.key -out proj.crt

$ kubectl create secret generic ssl --from-file=crt=./proj.crt --from-file=key=./proj.key

$ kubectl create secret generic db --from-literal=password=my_secret_password

$ IMAGE="local/proj:latest" ALLOWED_HOSTS="*" envsubst < ./config/deployment.yaml | kubectl apply -f -


$ minikube service proj-service
```

which should open your browser with the port for the proj
