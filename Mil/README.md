# Remote compile on linux settings

```
export GNUTLS_CPUID_OVERRIDE=0x1

sudo apt-get install xserver-xorg-core --no-install-recommends --no-install-suggests
sudo apt-get install openbox --no-install-recommends --no-install-suggests
sudo apt-get install xinit
sudo apt-get install slim
sudo apt-get install x11-apps

sudo adduser rverma sudo
sudo chown -R username:username /home/username/.ssh
sudo chmod 0700 /home/username/.ssh
sudo chmod 0600 /home/username/.ssh/authorized_keys
```