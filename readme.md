# Login tool

```shell
pip install -r requirements.txt
python ./cli.py --server vpn.sjsu.edu --authgroup Student-SSO
```

Then, you can get your command line and cookie.

`Command Line:  sudo openconnect --useragent "AnyConnect Linux_64 4.7.00136" --version-string 4.7.00136 --cookie-on-stdin --servercert 1B4736219BED9631CC64DFD2A624D852AF1A1F43 https://vpn.sjsu.edu/`

`Session Token:  ********@**********@******@**********************`

# Docker Build

```shell
docker build -t oc-socks-gateway .
docker run -d --name oc-socks \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -p 10808:1080 \
    -e VPN_SERVER="https://vpn.sjsu.edu/" \
    -e VPN_PASSWORD="********@**********@******@**********************" \
    oc-socks-gateway
```
Alternate Env:

```shell
VPN_USER_AGENT=${VPN_USER_AGENT:-"AnyConnect Linux_64 4.7.00136"}
VPN_VERSION_STRING=${VPN_VERSION_STRING:-"4.7.00136"}
VPN_PROTOCOL=${VPN_PROTOCOL:-"anyconnect"}
```

# Docker Prebuild

```shell
docker pull ghcr.io/seey6/oc2socks
docker run -d --name oc2socks ...
```
