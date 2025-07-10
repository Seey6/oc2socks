# oc2socks: OpenConnect with SSO to SOCKS5 Proxy

<p align="center">
<b>English</b> | <a href="https://github.com/Seey6/oc2socks/blob/main/readme_cn.md">简体中文</a>
</p>

`oc2socks` is a Dockerized tool that seamlessly converts an OpenConnect VPN connection requiring SSO (Single Sign-On) web authentication into a local SOCKS5 proxy. This allows any application on your system to connect through the VPN without complex configurations.

### ✨ Features

  * **SSO Login Support**: Uses a Python-based tool (`sso-login-tool`) to handle browser-based SSO authentication and retrieve the session cookie.
  * **One-Command Setup**: Run the entire service with a single `docker run` command after obtaining the token.
  * **Clean & Isolated**: Docker containerization ensures that VPN routing rules do not affect your host machine's network configuration.
  * **Pre-built Image**: A pre-built Docker image is available on GitHub Container Registry (GHCR) for quick deployment.
  * **Highly Configurable**: Supports custom VPN protocols, user agents, and SOCKS ports via environment variables.

-----

## 🚀 How to Use

The process involves two main steps:

1.  **Get the Session Token**: Use the `sso-login-tool` to authenticate via a browser and get a session token.
2.  **Run the Docker Container**: Start the `oc2socks` container with the obtained token.

### Step 1: Get the Session Token

This token acts as a one-time password for the OpenConnect connection.

1.  **Prerequisites**: Ensure you have Python 3 and `pip` installed.

2.  **Install Dependencies**: Clone this repository and install the required Python packages for the login tool.

    ```shell
    git clone https://github.com/seey6/oc2socks.git
    cd oc2socks/sso-login-tool
    pip install -r requirements.txt
    ```

3.  **Run the Login Script**: Execute the `cli.py` script. It will automatically open a browser window for you to complete the SSO login process.

      * Replace `vpn.sjsu.edu` with your VPN server address.
      * Replace `Student-SSO` with your specific authentication group if required. If not, you can omit the `--authgroup` parameter.

    <!-- end list -->

    ```shell
    python ./cli.py --server vpn.sjsu.edu --authgroup Student-SSO
    ```

    Upon successful login, the script will output the command line and the session token to your terminal.

4.  **Copy the Session Token**: This is the most crucial part. Copy the long string labeled **`Session Token`**. You will use this as the `VPN_PASSWORD` in the next step.

    ```text
    Command Line:  sudo openconnect --useragent ... --servercert ... https://vpn.sjsu.edu/
    Session Token:  ********@**********@******@********************** <- COPY THIS VALUE
    ```

### Step 2: Run the oc2socks Container

Now, use the token to start the proxy service.

#### Option A: Use Pre-built Docker Image (Recommended)

This is the easiest way to get started.

1.  **Pull the Image**:

    ```shell
    docker pull ghcr.io/seey6/oc2socks
    ```

2.  **Run the Container**:

    ```shell
    docker run -d --name oc2socks \
        --cap-add=NET_ADMIN \
        --device=/dev/net/tun \
        -p 1080:1080 \
        -e VPN_SERVER="vpn.sjsu.edu" \
        -e VPN_PASSWORD="<PASTE_YOUR_SESSION_TOKEN_HERE>" \
        ghcr.io/seey6/oc2socks
    ```

#### Option B: Build from Source

If you want to customize the tool, you can build the image yourself.

1.  **Build the Image**: In the project root directory, run:

    ```shell
    docker build -t oc-socks-gateway .
    ```

2.  **Run the Container**:

    ```shell
    docker run -d --name oc-socks \
        --cap-add=NET_ADMIN \
        --device=/dev/net/tun \
        -p 1080:1080 \
        -e VPN_SERVER="vpn.sjsu.edu" \
        -e VPN_PASSWORD="<PASTE_YOUR_SESSION_TOKEN_HERE>" \
        oc-socks-gateway
    ```

### Step 3: Configure Your SOCKS5 Proxy

Once the container is running, a SOCKS5 proxy will be available on your host machine. Configure your applications or system network settings to use it:

  * **Proxy Server**: `127.0.0.1`
  * **Port**: `1080` (or the host port you mapped)
  * **Type**: SOCKS5

-----

### 🔧 Environment Variables

You can customize the container's behavior with these environment variables:

| Variable             | Description                                          | Default Value                 |
| -------------------- | ---------------------------------------------------- | ----------------------------- |
| `VPN_SERVER`         | **(Required)** Your VPN server address.              | (None)                        |
| `VPN_PASSWORD`       | **(Required)** The session token obtained in Step 1. | (None)                        |
| `SOCKS_PORT`         | The port for the SOCKS5 proxy inside the container.  | `1080`                        |
| `VPN_PROTOCOL`       | The VPN protocol to use (e.g., `anyconnect`, `gp`).  | `anyconnect`                  |
| `VPN_USER_AGENT`     | User-Agent string for the OpenConnect client.        | `AnyConnect Linux_64 4.7.00136` |
| `VPN_VERSION_STRING` | Version string for the OpenConnect client.           | `4.7.00136`                   |

### Thanks
[openconnect-sso](https://github.com/vlaci/openconnect-sso)