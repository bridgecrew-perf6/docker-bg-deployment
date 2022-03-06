# docker-bg-deployment

sample of blue/green deployment.

## containers

 - loadbalancer
   - https://github.com/cubicdaiya/ngx_dynamic_upstream
 - application (app-blue and app-green)
   - https://github.com/docker/getting-started

## usage

### setup

If you execute `deploy.sh` for the first time, `loadbalancer` and `app-blue` will be started.

```sh
git clone https://github.com/rsym/docker-bg-deployment.git
cd docker-bg-deployment
sh deploy.sh
```

```sh
$ docker compose ps
NAME                COMMAND                  SERVICE             STATUS              PORTS
app-blue            "/docker-entrypoint.…"   app-blue            running             80/tcp
loadbalancer        "nginx -g 'daemon of…"   loadbalancer        running             0.0.0.0:80->80/tcp, :::80->80/tcp
```

### blue/green deployment

You can do blue/green deployment, every executing `deploy.sh`.
```sh
sh deploy.sh
```

#### example

```sh
$ sh deploy.sh
[+] Running 1/1
 ⠿ app-green Pulled                                                                                                             2.4s
[+] Running 1/1
 ⠿ Container app-green  Started                                                                                                 0.7s
server 192.168.32.2:80 weight=1 max_fails=1 fail_timeout=10;
server 192.168.32.3:80 weight=1 max_fails=1 fail_timeout=10;
server 192.168.32.2:80 weight=1 max_fails=1 fail_timeout=10 down;
server 192.168.32.3:80 weight=1 max_fails=1 fail_timeout=10;
[+] Running 1/1
 ⠿ Container app-blue  Stopped                                                                                                  0.2s
Going to remove app-blue
[+] Running 1/0
 ⠿ Container app-blue  Removed                                                                                                  0.0s
deployment is completed!
===== current upstream =====
server 192.168.32.2:80 down;
server 192.168.32.3:80;
===== current service =====
NAME                COMMAND                  SERVICE             STATUS              PORTS
app-green           "/docker-entrypoint.…"   app-green           running             80/tcp
loadbalancer        "nginx -g 'daemon of…"   loadbalancer        running             0.0.0.0:80->80/tcp, :::80->80/tcp

```
