# Table of Contents
tbd

# Project Structure
tbd

# Development Environment
tbd

# Project Setup

The steps in this section need to be done before running the ansible script.

## Java

The following Java Versions need to be present on the cluster.

- **Java 8** – for HDFS, YARN, Hive, etc.
- **Java 17** – for Spark, Kafka, etc.

### Configuration

Set the `file` and `home_path` variables in `group_vars/all.yml`

- `file` - name of the `.tar.gz` that is located in the directory of the respective CPU architecture.
- `home_path` - the home path of the Java Version which is used for example to create a symbolic link.

```yml
java:
  jdk_8:
    file: "amazon-corretto-8.482.08.1-linux-x64.tar.gz"
    home_path: "/opt/jdk-8"
  jdk_17:
    file: "amazon-corretto-17.0.18.9.1-linux-x64.tar.gz"
    home_path: "/opt/jdk-17"
```

### Download

For Ansible to distribute the JDK on the cluster, it must be present in the files directory of the `system` Ansible Role (`roles/system/files/`). The version for the specific system architecture must be located in the appropriate sub-directory.

```text
roles/system/files/
└── jdk
    ├── aarch64
    |   └── ...  
    └── x86_64
        ├── amazon-corretto-17.0.18.9.1-linux-x64.tar.gz
        └── amazon-corretto-8.482.08.1-linux-x64.tar.gz
```

- [Amazon Coretto](https://aws.amazon.com/corretto/)
- [Amazon Coretto JDK 8](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html)
- [Amazon Coretto JDK 17](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html)

The following command will download and rename the tarball to be architecture-agnostic. Ansible will semi-automatically select the correct file using the directory structure. Run the following commands in the root directory of the ansible project.

For x64 architecture:

```shell
curl \
--location https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.tar.gz \
--create-dirs \
--remote-name \ 
--output-dir roles/system/files/jdk/x86_64/

curl \
--location https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz \
--create-dirs \
--remote-name \ 
--output-dir roles/system/files/jdk/x86_64/
```

For ARM architecture:

```bash
curl \
--location https://corretto.aws/downloads/latest/amazon-corretto-8-aarch64-linux-jdk.tar.gz \
--create-dirs \
--remote-name \ 
--output-dir roles/system/files/jdk/aarch64/

curl \
--location https://corretto.aws/downloads/latest/amazon-corretto-17-aarch64-linux-jdk.tar.gz \
--create-dirs \
--remote-name \ 
--output-dir roles/system/files/jdk/aarch64/
```

After installation, JDK 8 and 17 will be available in the `/opt` directory on each host:

```text
lrwxrwxrwx  1 root root   20 Sep  9 18:35 jdk-17 -> /opt/amazon-corretto-17.0.18.9.1-linux-x64/
drwxr-xr-x  3 root root 4096 Sep  9 18:43 amazon-corretto-17.0.18.9.1-linux-x64/
lrwxrwxrwx  1 root root   19 Sep  9 18:35 jdk-8 -> /opt/amazon-corretto-8.482.08.1-linux-x64/
drwxr-xr-x  3 root root 4096 Sep  9 18:43 amazon-corretto-8.482.08.1-linux-x64/
```

## Packages

Packages that need to be present on all hosts in the cluster that will be installed through the `apt` package manger.

`group_vars/all.yml`:

```yaml
apt_packages:
  - acl
  - python3-pip
  - python3.10-venv
```

## Users

### Service Users

Technical Users that are required to run certain services.

### Cluster Users

The actual personal users that will use the services provided by the cluster.

# Usage

```shell
ansible-playbook -i inventory/vm setup_cluster.yml --tags "system"
```

## Troubleshooting

The following error occured on CachyOS (Arch based Linux distribution). To fix this I had to install an `ssh-askpass` implementation and then export an environment variable `export SSH_ASKPASS='/usr/bin/ksshaskpass`
`
```text
vm1 | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh_askpass: exec(/usr/lib/ssh/ssh-askpass): No such file or directory\r\nHost key verification failed.",
    "unreachable": true

```
```bash
sudo pacman -S ksshaskpass
export SSH_ASKPASS='/usr/bin/ksshaskpass'
```