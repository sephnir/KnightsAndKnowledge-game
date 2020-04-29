## Prerequisites

- [Godot Engine v3.2](https://godotengine.org/)

## Setup

- Edit *Global.gd*, change *HOSTNAME* and *PORT* to the server's IP and port number.
- *CLIENT_ID* and *CLIENT_GRANT* should hold the password grant token. (If database is seeded using `php artisan db:seed`, leave it as it is. Otherwise, look for the token in the *oauth_clients* table after executing `php artisan passport:client --password` at the server)
```
const HOSTNAME = "127.0.0.1";
const PORT = 8000;

const CLIENT_ID = 1;
const CLIENT_GRANT = "TzzipodhcJHdkv8bhIC37st3z9MBKn94MRRtw1Tw";
```

