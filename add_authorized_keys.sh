#! /bin/bash

KEY_NAME='id_ed25519'
USER='ansible'
HOSTS=('vm-controller' 'vm-worker01' 'vm-worker02' 'vm-worker03')
HOSTS=('vm-worker02')

cd ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/${KEY_NAME}

for HOST in "${HOSTS[@]}"
do
    ssh $USER@$HOST 'mkdir -p ~/.ssh'
    scp ~/.ssh/${KEY_NAME}.pub $USER@$HOST:~/.ssh/${KEY_NAME}.pub
    ssh $USER@$HOST "cat ~/.ssh/$KEY_NAME.pub >> ~/.ssh/authorized_keys"
done