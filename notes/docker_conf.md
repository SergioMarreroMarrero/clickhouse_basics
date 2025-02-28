
Para habilitarle opciones de red tenemos que iniciar el usuario con contraseña. Tambien es conveniente definir explicitamente
los puertos. Tambien hubo algun problema con el firewall y hubo que habilitar manualmente el puerto.

```bash
docker run -d -p 8123:8123 -p 9000:9000 -e CLICKHOUSE_PASSWORD=clickhouse --ulimit nofile=262144:262144 --name clickhouse clickhouse/clickhouse-server:latest
docker container ls -- lsitamos containers
docker ps -a -- lsitamos containers
docker exec -it 0e0 /bin/bash -- con esto entramos dentro del servidor
clickhouse-client
```

Para apagar el docker y encender:

```bash
docker stop clickhouse
docker restart clickhouse
```


si quisiera que el contenedor se iniciara con el equipo:

```bash
docker run -d --restart always -p 8123:8123 -p 9000:9000 \
  -e CLICKHOUSE_PASSWORD=clickhouse \
  --name clickhouse clickhouse/clickhouse-server:latest

o

docker update --restart always clickhouse
```

para eliminarlo. En este caso si no se crearon volumenes persistentes los datos se borraran.

```bash
docker rm -f clickhouse
```