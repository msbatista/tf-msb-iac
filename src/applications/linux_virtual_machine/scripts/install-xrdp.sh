az vm run-command invoke -g ${RG_NAME} -n ${VM_NAME} --command-id RunShellScript --scripts "sudo apt-get update && \\
sudo apt-get -y install xfce4 && \\
sudo apt install -y xfce4-session && \\
sudo apt-get -y install xrdp && \\
sudo systemctl enable xrdp && \\
sudo service xrdp restart
"