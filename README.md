# Instructions

## Tips

disable unattended upgrades to avoid confilcts, needs to be done once on each host

```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

- Use the download the versions that are already configured in the playbooks since the installation prcedure might vary for different versions.
- Run the command with `--diff --check` first to avoid problems.

## 1. Linux Setup

Installing required packages

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/install-packages.yml
```

Generate /etc/hosts file on each host

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/generate-hosts-file.yml
```

## 2. Install Hadoop

Create hadoop user.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/create-user.yml -e "new_user=hadoop"
```

Installing hadoop, make sure that the hadoop tarball file is located ad `/playbooks/hadoop/files/` and the correct version is configured in the playbook. https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hadoop/install.yml
```

Format the NameNode.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hadoop/format-namenode.yml
```

Start Services.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hadoop/start-services.yml
```

Wait a couple of minutes unitl all services are up.  
Then configure YARN directories.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hadoop/configure-yarn-dir.yml
```

## 3. Hive

### Setup Metastore

Install MySQL

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/mysql/install.yml
```

Create Metastore DB User.  
Running this command will create the user. Ensure to replace the password with the one set in `hive-site.xml`.
If you are using special characters you might need to escape them (e.g "n!ce" --> "n\\!ce")

```bash
ansible-playbook \
-i inventory/vm-inventory.yml \
-e "user=hive" \
-e "pass=Sup3rS3cur3Pa55w0rd\!" \
-e "db=hive_metastore"  \
-e "table=*" \
-e "privileges=ALL" \
playbooks/mysql/create-user.yml
```

### Hive installation

Create hive user.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/create-user.yml -e "new_user=hive"
```

- Installing hive, make sure that the hive tarball file is located ad `/playbooks/hive/files/` and the correct version is configured in the playbook. https://dlcdn.apache.org/hive/hive-3.1.3/
- Place MySQL connector jar file in `/playbooks/hive/files/`, check if it is named correctly. https://www.mysql.com/products/connector/ Download JDBC Driver and choose platform independent. The `.jar` is placed inside an archive, extract it and only place the `.jar` in the folder mentioned above.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hive/install.yml
```

Start Services.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/hive/start-services.yml
```

# 4. Kafka

Create kafka user.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/create-user.yml -e "new_user=kafka"
```

Installing kafka, make sure that the kafka tarball file is located ad `/playbooks/kafka/files/` and the correct version is configured in the playbook. https://kafka.apache.org/downloads

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/kafka/install.yml
```

Starting the cluster.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/kafka/start-cluster.yml
```

# Kerberos

Create kerberos user.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/linux/create-user.yml -e "new_user=kerberos"
```

Install KDC and Admin-Server on Master node and User Client on all nodes.

```bash
ansible-playbook -i inventory/vm-inventory.yml playbooks/kerberos/install.yml
```

Create Database

```bash
ansible-playbook \
-i inventory/vm-inventory.yml \
-e "pass=$PASS" \
playbooks/kerberos/create_db.yml
```

Add Principals

```bash
ansible-playbook \
-i inventory/vm-inventory.yml \
-e "user=bernhard" \
-e "pass=$PASS" \
-e "instance=admin" \
playbooks/kerberos/add_princ.yml
```
