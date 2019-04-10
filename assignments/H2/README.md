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

Luodaan masterilla sshd-tila:
```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/sshd.sls
[smtnskn@ERIDU ~]$ cat /srv/salt/sshd.sls
openssh-server:
  pkg.installed

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd_config
```

...sekä sen käyttämä sshd_config -tiedosto:
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

#### 2.

Asennetaan Apache:
```
smtnskn@ubuserver:~$ sudo apt-get install apache2 -y
```
Kokeillaan näkyykö oletussivu:

![apache-default](/assignments/H2/images/apache-default.png)

Luodaan käyttäjälle oma sivu ja otetaan se käyttöön:
```
smtnskn@ubuserver:~$ mkdir ~/public_html
smtnskn@ubuserver:~$ nano ~/public_html/index.html
smtnskn@ubuserver:~$ cat ~/public_html/index.html
<!doctype html>
<html lang=en>

<head>
	<meta charset=utf-8>
	<title>A website</title>
</head>
<body>
  <center>
  	<h1>Testi</h1>
  </center>
</body>
</html>
smtnskn@ubuserver:~$ sudo a2enmod userdir
Enabling module userdir.
To activate the new configuration, you need to run:
  systemctl restart apache2
smtnskn@ubuserver:~$ sudo systemctl restart apache2
```
Kokeillaan näkyykö käyttäjän sivu:

![apache-user-enabled](/assignments/H2/images/apache-user-enabled.png)

Luodaan tila, joka automatisoi käyttäjien sivujen käyttöönoton. Katsotaan ensin, mitä asetustiedostoja tarvitsemme:
```
smtnskn@ubuserver:~$ sudo find /etc/ -printf '%T+ %p\n' | sort | tail -n 5
2019-04-09+20:40:56.4938979250 /etc/ld.so.cache
2019-04-09+20:40:56.5058977270 /etc/
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled/userdir.conf
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled/userdir.load
```
Vain 2. Luodaan itse tila ja symlinkataan sillä nuo tiedostot:
```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/apache.sls
[smtnskn@ERIDU ~]$ sudo cat /srv/salt/apache.sls
apache2:
  pkg.installed

/etc/apache2/mods-enabled/userdir.conf:
  file.symlink:
    - target: /etc/apache2/mods-available/userdir.conf

/etc/apache2/mods-enabled/userdir.load:
  file.symlink:
    - target: /etc/apache2/mods-available/userdir.load
```
Laitetaan minionilla käyttäjäsivut pois päältä:
```
smtnskn@ubuserver:~$ sudo a2dismod userdir
Module userdir disabled.
To activate the new configuration, you need to run:
  systemctl restart apache2
smtnskn@ubuserver:~$ systemctl restart apache2
```
Varmistetaan:

![apache-user-disabled](/assignments/H2/images/apache-user-disabled.png)

Laitetaan ne takaisin päälle Saltin avulla:
```
[smtnskn@ERIDU ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

ubuserver:
----------
          ID: apache2
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 21:46:38.470224
    Duration: 244.977 ms
     Changes:   
----------
          ID: /etc/apache2/mods-enabled/userdir.conf
    Function: file.symlink
      Result: True
     Comment: Created new symlink /etc/apache2/mods-enabled/userdir.conf -> /etc/apache2/mods-available/userdir.conf
     Started: 21:46:38.718167
    Duration: 1.036 ms
     Changes:   
              ----------
              new:
                  /etc/apache2/mods-enabled/userdir.conf
----------
          ID: /etc/apache2/mods-enabled/userdir.load
    Function: file.symlink
      Result: True
     Comment: Created new symlink /etc/apache2/mods-enabled/userdir.load -> /etc/apache2/mods-available/userdir.load
     Started: 21:46:38.719276
    Duration: 0.746 ms
     Changes:   
              ----------
              new:
                  /etc/apache2/mods-enabled/userdir.load

Summary for ubuserver
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time: 246.759 ms
```

Tarkistetaan:

![apache-user-disabled-2](/assignments/H2/images/apache-user-disabled-2.png)

Ei toimi. Unohdin käynnistää Apachen uudelleen. Laitan sivut pois päältä kuten aiemmin (```sudo a2dismod userdir```) ja korjaan tilan:
```
[smtnskn@ERIDU ~]$ sudo cat /srv/salt/apache.sls 
apache2:
  pkg.installed
  service.running:
    - watch:
      - file: /etc/apache2/mods-enabled/userdir.conf
      - file: /etc/apache2/mods-enabled/userdir.load

/etc/apache2/mods-enabled/userdir.conf:
  file.symlink:
    - target: /etc/apache2/mods-available/userdir.conf

/etc/apache2/mods-enabled/userdir.load:
  file.symlink:
    - target: /etc/apache2/mods-available/userdir.load
[smtnskn@ERIDU ~]$ 
```

Suoritan ```sudo salt '*' state.apply apache```:
```
[smtnskn@ERIDU ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

ubuserver:
    Data failed to compile:
----------
    Rendering SLS 'base:apache' failed: mapping values are not allowed here; line 3

---
apache2:
  pkg.installed
  service.running:    <======================
    - watch:
      - file: /etc/apache2/mods-enabled/userdir.conf
      - file: /etc/apache2/mods-enabled/userdir.load

/etc/apache2/mods-enabled/userdir.conf:
[...]
---
ERROR: Minions returned with non-zero exit code
```

Jaha. Lisää muutoksia:
```
[smtnskn@ERIDU ~]$ sudo nano /srv/salt/apache.sls 
[smtnskn@ERIDU ~]$ sudo head -n 2 /srv/salt/apache.sls 
apache2:
  pkg.installed: []
```

Eli muutin ```pkg.installed``` -> ```pkg_installed: []```
Uusi uritys:
```
[smtnskn@ERIDU ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

ubuserver:
----------
          ID: apache2
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 22:11:05.003529
    Duration: 256.378 ms
     Changes:   
----------
          ID: /etc/apache2/mods-enabled/userdir.conf
    Function: file.symlink
      Result: True
     Comment: Created new symlink /etc/apache2/mods-enabled/userdir.conf -> /etc/apache2/mods-available/userdir.conf
     Started: 22:11:05.264370
    Duration: 1.167 ms
     Changes:   
              ----------
              new:
                  /etc/apache2/mods-enabled/userdir.conf
----------
          ID: /etc/apache2/mods-enabled/userdir.load
    Function: file.symlink
      Result: True
     Comment: Created new symlink /etc/apache2/mods-enabled/userdir.load -> /etc/apache2/mods-available/userdir.load
     Started: 22:11:05.265616
    Duration: 0.815 ms
     Changes:   
              ----------
              new:
                  /etc/apache2/mods-enabled/userdir.load
----------
          ID: apache2
    Function: service.running
      Result: True
     Comment: Service restarted
     Started: 22:11:05.293301
    Duration: 134.469 ms
     Changes:   
              ----------
              apache2:
                  True

Summary for ubuserver
------------
Succeeded: 4 (changed=3)
Failed:    0
------------
Total states run:     4
Total run time: 392.829 ms
```

No niin! Ja kokeillaan sivua:

![apache-user-enabled-2](/assignments/H2/images/apache-user-enabled-2.png)

---

#### 3.

