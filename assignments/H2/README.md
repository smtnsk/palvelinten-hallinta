## H2 - Package-file-server.

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto (torstain ryhmä):

1. Asenna SSH eri porttiin Package-File-Service rakenteella. Käytä service:watch -tekniikkaa niin, että demoni käynnistyy uudelleen, kun asetustiedosto muuttuu.

2. Asenna Apache käsin niin, että käyttäjien kotisivut näkyvät. Etsi muutetut tiedostot komennolla ‘find /etc/ -printf ‘%T+ %p\n’|sort’. (Muista korjata lainausmerkit oikeiksi, automaattimuotoilu usein sotkee ne). Yritä nyt tehdä tila, joka asettaa nuo tiedostot (file.symlink) paikoilleen.

3. Eri package-file-service. Tee package-file-service tilalla jokin eri asetus tai asennus kuin tunnilla ja tehtävän muissa kohdissa.

#### Ympäristö:

Master (hostname ERIDU): Pilvipalvelimella pyörivä Parabola GNU/Linux-libre x64.\
Minion (hostname ubuserver): Hyper-V -virtuaalikoneella pyörivä Ubuntu 18.04.2 LTS x64, isäntäkoneella Windows Embedded 8.1 Industry Pro x64.

Lisäksi käytössä läppäri, hostnamella LAPTOP.

---

#### 1.

Luon masterilla sshd-tilan:
```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/sshd.sls
[smtnskn@ERIDU ~]$ cat /srv/salt/sshd.sls
openssh-server:
  pkg.installed

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd_config
```

...sekä sen käyttämän sshd_config -tiedoston:
```
[smtnskn@ERIDU ~]$ sudo cp -v /etc/ssh/sshd_config /srv/salt/
'/etc/ssh/sshd_config' -> '/srv/salt/sshd_config'
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/sshd_config
[smtnskn@ERIDU ~]$ sudo cat /srv/salt/sshd_config
## Managed file - DO NOT EDIT

Protocol 2
Port 8888
HostKey	/etc/ssh/ssh_host_rsa_key
HostKey	/etc/ssh/ssh_host_ecdsa_key
HostKey	/etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 2m
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
PubkeyAuthentication yes
HostbasedAuthentication	no
IgnoreRhosts yes
PermitEmptyPasswords no
ChallengeResponseAuthentication	no
UsePAM yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG_LC_*

Subsystem	sftp	/usr/lib/ssh/sftp-server
```

Käsketään minionia ottamaan asetukset käyttöön:
```
[smtnskn@ERIDU ~]$ sudo salt '*' state.apply sshd
ubuserver:
----------
          ID: openssh-server
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 19:40:18.495636
    Duration: 246.697 ms
     Changes:   
----------
          ID: /etc/ssh/sshd_config
    Function: file.managed
      Result: True
     Comment: File /etc/ssh/sshd_config updated
     Started: 19:40:18.748877
    Duration: 666.871 ms
     Changes: 
```
[pitkä diff leikattu pois]
```
Summary for ubuserver
------------
Succeeded: 2 (changed=1)
Failed:    0
------------
Total states run:     2
Total run time: 913.568 ms
```

Kokeillaan toimiiko:
```
smtnskn@ubuserver:~$ sudo systemctl restart ssh.service
```
```
LAPTOP:smtnskn ~> ssh smtnskn@192.168.2.103 -p 8888
The authenticity of host '[192.168.2.103]:8888 ([192.168.2.103]:8888)' can't be established.
ECDSA key fingerprint is SHA256:000mo4mSV66LNT4Qn5d6q5gax8TfzBegrkuEy3m016E.
Are you sure you want to continue connecting (yes/no)? y
Please type 'yes' or 'no': yes
Warning: Permanently added '[192.168.2.103]:8888' (ECDSA) to the list of known hosts.
Enter passphrase for key '/Users/smtnskn/.ssh/id_ed25519': 
Welcome to Ubuntu 18.04.2 LTS (GNU/Linux 4.15.0-47-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue Apr  9 19:50:50 UTC 2019

  System load:  0.0               Processes:           99
  Usage of /:   45.2% of 9.78GB   Users logged in:     1
  Memory usage: 28%               IP address for eth0: 192.168.2.103
  Swap usage:   0%

 * Ubuntu's Kubernetes 1.14 distributions can bypass Docker and use containerd
   directly, see https://bit.ly/ubuntu-containerd or try it now with

     snap install microk8s --classic

0 packages can be updated.
0 updates are security updates.


Last login: Tue Apr  9 17:58:39 2019 from 192.168.2.102
smtnskn@ubuserver:~$ 
```

Toimii. Laitetaan vielä ssh -service käynnistymään uudelleen aina sshd_config -tiedoston muuttuessa lisäämällä sshd -tilan loppuun seuraavaa:

```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/sshd.sls
[smtnskn@ERIDU ~]$ sudo tail -n 5 /srv/salt/sshd.sls

sshd:
  service.running:
    - watch:
      - file: /etc/ssh/sshd_config
```

Tehdään sshd_configiin muutos masterin puolella ja pusketaan se minionille:
```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/sshd_config
[smtnskn@ERIDU ~]$ sudo head -n 5 /srv/salt/sshd_config 
## Managed file - DO NOT EDIT

## hi, this is a test

Protocol 2
[smtnskn@ERIDU ~]$ sudo salt '*' state.apply sshd
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

ubuserver:
----------
          ID: openssh-server
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 20:14:46.725869
    Duration: 254.188 ms
     Changes:   
----------
          ID: /etc/ssh/sshd_config
    Function: file.managed
      Result: True
     Comment: File /etc/ssh/sshd_config updated
     Started: 20:14:46.983016
    Duration: 684.8 ms
     Changes:   
              ----------
              diff:
                  --- 
                  +++ 
                  @@ -1,4 +1,6 @@
                   ## Managed file - DO NOT EDIT
                  +
                  +## hi, this is a test
                   
                   Protocol 2
                   Port 8888
----------
          ID: sshd
    Function: service.running
      Result: True
     Comment: Service restarted
     Started: 20:14:47.754349
    Duration: 95.009 ms
     Changes:   
              ----------
              sshd:
                  True

Summary for ubuserver
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time:   1.034 s
```

Ja tarkistetaan vielä minionin puolella:

```
smtnskn@ubuserver:~$ head -n 5 /etc/ssh/sshd_config
## Managed file - DO NOT EDIT

## hi, this is a test

Protocol 2
smtnskn@ubuserver:~$ 
```
---
