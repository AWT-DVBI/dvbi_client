# DVB-I Client and Parser

## Development Setup

Install the [Nix package manager](https://nixos.org/download.html):
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Clone the repository:
```
git clone --recursive git@github.com:AWT-DVBI/dvbi_client.git
```

Drop into a development shell with all dependencies pinned by a hash with:
```
nix-shell
``` 

Try building and running the Flutter application
```
cd dvbi_client && flutter run
```

Afterwards open a ready to use vscodium for the project:
```
code .
```
