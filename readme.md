# minecraft auto

This is an automatic script that provisions a t3.small AWS instance and installs the latest version of the Minecraft server software on it using Docker.

## Requirements

You must have the lastest version of Terraform installed. This is most easily done using Snap:

```bash
sudo snap install terraform
```

The AWS CLI is also required. It may be in your distribution's repositories, usually a package called `awscli`.

```bash
# Use your distro's package manager to install
sudo apt install awscli
sudo dnf install awscli
```

AWS credentials should be stored in `~/.aws/credentials`.

## Usage

Usage is extremely simple. Just run `./install.sh` in the terminal. **Bash is required. It works on Fedora Linux but not tested on other systems!**

## What does it do?

1. The script checks for whether AWS credentials, `awscli`, and Terraform are all present.
2. Terraform dependencies are then downloaded to the current folder.
3. SSH keys are generated and stored at `./tf-key-pair`. An EC2 security group will be created that allows SSH and Minecraft traffic from 0.0.0.0/0, and outbound traffic to anywhere.
4. An EC2 (t2.small) instance will be launched running Ubuntu 20.04 LTS. Docker will be installed on it using Snap and then the Minecraft server software will be downloaded using Docker.
5. Minecraft is configured to start automatically when the server boots up and restart upon failure.
6. Please wait five minutes for the Minecraft server to be downloaded and started. This takes a long time and the script will finish before it's done because it takes a variable (and long) amount of time.