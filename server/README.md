BSK Projekt
===========

Nothing interesting. Move on.

Installation
------------
1. Install Elixir environment
2. Generate server certificates (server.crt and server.key)
3. Run `iex -S mix`
4. Server runs on port 24948

Generating certificates
-----------------------
```
# Common Name = localhost
openssl ecparam -name secp521r1 -out server.key -genkey
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
```
