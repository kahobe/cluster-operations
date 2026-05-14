#! /bin/bash

KEY_NAME='id_ed25519'
USER='ansible'
HOSTS=('rpic' 'rpiw1' 'rpiw2' 'rpiw3')
HOSTS=('vm-controller' 'vm-worker01')

cd ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/${KEY_NAME}

for HOST in "${HOSTS[@]}"
do
    ssh $USER@$HOST 'mkdir -p ~/.ssh'
    scp ~/.ssh/${KEY_NAME}.pub $USER@$HOST:~/.ssh/${KEY_NAME}.pub
    ssh $USER@$HOST "cat ~/.ssh/$KEY_NAME.pub >> ~/.ssh/authorized_keys"
done
