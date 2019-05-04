## H2 - Package-file-server.

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto (torstain ryhmä):

1. Asenna SSH eri porttiin Package-File-Service rakenteella. Käytä service:watch -tekniikkaa niin, että demoni käynnistyy uudelleen, kun asetustiedosto muuttuu.

2. Asenna Apache käsin niin, että käyttäjien kotisivut näkyvät. Etsi muutetut tiedostot komennolla ‘find /etc/ -printf ‘%T+ %p\n’|sort’. (Muista korjata lainausmerkit oikeiksi, automaattimuotoilu usein sotkee ne). Yritä nyt tehdä tila, joka asettaa nuo tiedostot (file.symlink) paikoilleen.

3. Eri package-file-service. Tee package-file-service tilalla jokin eri asetus tai asennus kuin tunnilla ja tehtävän muissa kohdissa.

#### Ympäristö:

Master (hostname MASTER): Pilvipalvelimella pyörivä Parabola GNU/Linux-libre x64.\
Minion (hostname MINION): Hyper-V -virtuaalikoneella pyörivä Ubuntu 18.04.2 LTS x64, isäntäkoneella Windows Embedded 8.1 Industry Pro x64.

Lisäksi käytössä MacBook Air, hostnamella LAPTOP.

---

### 1. SSH:n asennus, Package-File-Service

Luodaan masterilla sshd-tila:
```
[smtnskn@MASTER ~]$ sudo nano /srv/salt/sshd.sls
[smtnskn@MASTER ~]$ cat /srv/salt/sshd.sls
openssh-server:
  pkg.installed

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd_config
```

...sekä sen käyttämä sshd_config -tiedosto:
```
[smtnskn@MASTER ~]$ sudo cp -v /etc/ssh/sshd_config /srv/salt/
'/etc/ssh/sshd_config' -> '/srv/salt/sshd_config'
[smtnskn@MASTER ~]$ sudo nano /srv/salt/sshd_config
[smtnskn@MASTER ~]$ sudo cat /srv/salt/sshd_config
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
[smtnskn@MASTER ~]$ sudo salt '*' state.apply sshd
MINION:
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
Summary for MINION
------------
Succeeded: 2 (changed=1)
Failed:    0
------------
Total states run:     2
Total run time: 913.568 ms
```

Kokeillaan toimiiko:
```
smtnskn@MINION:~$ sudo systemctl restart ssh.service
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
smtnskn@MINION:~$ 
```

Toimii. Laitetaan vielä `ssh` -service käynnistymään uudelleen aina `sshd_config` -tiedoston muuttuessa lisäämällä `sshd` -tilan loppuun seuraavaa:

```
[smtnskn@MASTER ~]$ sudo nano /srv/salt/sshd.sls
[smtnskn@MASTER ~]$ sudo tail -n 5 /srv/salt/sshd.sls

sshd:
  service.running:
    - watch:
      - file: /etc/ssh/sshd_config
```

Tehdään sshd_configiin muutos masterin puolella ja pusketaan se minionille:
```
[smtnskn@MASTER ~]$ sudo nano /srv/salt/sshd_config
[smtnskn@MASTER ~]$ sudo head -n 5 /srv/salt/sshd_config 
## Managed file - DO NOT EDIT

## hi, this is a test

Protocol 2
[smtnskn@MASTER ~]$ sudo salt '*' state.apply sshd
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

MINION:
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

Summary for MINION
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time:   1.034 s
```

Ja tarkistetaan vielä minionin puolella:

```
smtnskn@MINION:~$ head -n 5 /etc/ssh/sshd_config
## Managed file - DO NOT EDIT

## hi, this is a test

Protocol 2
smtnskn@MINION:~$ 
```
---

### 2. Apachen asennus, kotisivut näkyviin

Asennetaan Apache:
```
smtnskn@MINION:~$ sudo apt-get install apache2 -y
```
Kokeillaan näkyykö oletussivu:

![apache-default](/assignments/H2/images/apache-default.png)

Luodaan käyttäjälle oma sivu ja otetaan se käyttöön:
```
smtnskn@MINION:~$ mkdir ~/public_html
smtnskn@MINION:~$ nano ~/public_html/index.html
smtnskn@MINION:~$ cat ~/public_html/index.html
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
smtnskn@MINION:~$ sudo a2enmod userdir
Enabling module userdir.
To activate the new configuration, you need to run:
  systemctl restart apache2
smtnskn@MINION:~$ sudo systemctl restart apache2
```
Kokeillaan näkyykö käyttäjän sivu:

![apache-user-enabled](/assignments/H2/images/apache-user-enabled.png)

Luodaan tila, joka automatisoi käyttäjien sivujen käyttöönoton. Katsotaan ensin, mitä asetustiedostoja tarvitsemme:
```
smtnskn@MINION:~$ sudo find /etc/ -printf '%T+ %p\n' | sort | tail -n 5
2019-04-09+20:40:56.4938979250 /etc/ld.so.cache
2019-04-09+20:40:56.5058977270 /etc/
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled/userdir.conf
2019-04-09+21:10:28.8076895180 /etc/apache2/mods-enabled/userdir.load
```
Vain 2. Luodaan itse tila ja symlinkataan sillä nuo tiedostot:
```
[smtnskn@MASTER ~]$ sudo nano /srv/salt/apache.sls
[smtnskn@MASTER ~]$ sudo cat /srv/salt/apache.sls
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
smtnskn@MINION:~$ sudo a2dismod userdir
Module userdir disabled.
To activate the new configuration, you need to run:
  systemctl restart apache2
smtnskn@MINION:~$ systemctl restart apache2
```
Varmistetaan:

![apache-user-disabled](/assignments/H2/images/apache-user-disabled.png)

Laitetaan ne takaisin päälle Saltin avulla:
```
[smtnskn@MASTER ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

MINION:
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

Summary for MINION
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time: 246.759 ms
```

Tarkistetaan:

![apache-user-disabled-2](/assignments/H2/images/apache-user-disabled-2.png)

Ei toimi. Unohdin käynnistää Apachen uudelleen. Laitan sivut pois päältä kuten aiemmin (`sudo a2dismod userdir`) ja korjaan tilan:
```
[smtnskn@MASTER ~]$ sudo cat /srv/salt/apache.sls 
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
[smtnskn@MASTER ~]$ 
```

Suoritan `sudo salt '*' state.apply apache`:
```
[smtnskn@MASTER ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

MINION:
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
[smtnskn@MASTER ~]$ sudo nano /srv/salt/apache.sls 
[smtnskn@MASTER ~]$ sudo head -n 2 /srv/salt/apache.sls 
apache2:
  pkg.installed: []
```

Eli muutin `pkg.installed` -> `pkg.installed: []`
Uusi uritys:
```
[smtnskn@MASTER ~]$ sudo salt '*' state.apply apache
[WARNING ] /usr/lib/python2.7/site-packages/salt/payload.py:149: DeprecationWarning: encoding is deprecated, Use raw=False instead.
  ret = msgpack.loads(msg, use_list=True, ext_hook=ext_type_decoder, encoding=encoding)

MINION:
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

Summary for MINION
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

### 3. Eri package-file-service

**EDIT (04.05.2019)**: Epäonnistuin tässä tehtävässä surkeasti aiemmin, joten palasin tämän pariin korjatakseni asian.

Ajatuksena on luoda Wireguard-tunneli masterin ja minionin välille. Masterilla on jo toimiva Wireguard asennus, jota en käy tässä läpi.

Aloitin luomalla `/srv/salt/wireguard` -hakemiston ja sinne `.list` -tiedoston, jonka `apt` tarvitsee tietääkseen, mistä repositoriosta Wireguard löytyy:\
![wireguard-repo](/assignments/H2/images/wireguard-repo.png)

Luon `init.sls` -tilan, joka lähettää tuon tiedoston minionille:\
![wireguard-sls-1](/assignments/H2/images/wireguard-sls-1.png)

Kokeilin:\
![wireguard-repo-success](/assignments/H2/images/wireguard-repo-success.png)

Sitten kokeilin asentaa itse Wireguardin:\
![wireguard-sls-2](/assignments/H2/images/wireguard-sls-2.png)
![wireguard-install](/assignments/H2/images/wireguard-install.png)

Onnistui.\
Jatkoin luomalla minionille omat avaimet:\
![minion-keys](/assignments/H2/images/minion-keys.png)

Tämä on vain testi, joten en piittaa turvallisuusriskeistä.

Loin myös minionille tunneliin tarvittavan konfiguraation, `wg0.conf`:\
![minion-wg-conf](/assignments/H2/images/minion-wg-conf.png)

Lisäsin kaikki nuo tiedostot tilaan, ja siihen päälle vielä Wireguardin käynnistyksen servicena:\
![wireguard-sls-3](/assignments/H2/images/wireguard-sls-3.png)

Muistikuvani on, että Wireguardia ei ole hyvä käyttää `systemctl`:n kautta, mutta katsotaan, miten käy:\
![wireguard-file-missing](/assignments/H2/images/wireguard-file-missing.png)

Hups, olin epähumiossa luonut `wg0.conf`:in `/srv/salt` -kansioon, joten `mv ../wg0.conf .`.\
Muistin samalla, että en ollut kertonut Wireguardille masterin puolella, että minionin yhteydenotot ovat ok. Tein sen nyt lisäämällä masterin asetuksiin seuraavaa:\
![wireguard-master](/assignments/H2/images/wireguard-master.png)

Uusi yritys:\
![wireguard-file-missing-2](/assignments/H2/images/wireguard-file-missing-2.png)

Nyt `wg0.conf` siirtyi onnistuneesti, mutta olin tehnyt kirjoitusvirheen tilaa tehdessä (huutomerkki viimeisellä rivillä).\
Korjasin asian ja kokeilin uudelleen:\
![wireguard-service-up-1](/assignments/H2/images/wireguard-service-up-1.png)

Lupaavaa. Wireguard-yhteys nimittäin estäisi Salttia kommunikoimasta.

Tässä vaiheessa ajauduin ongelmiin, sillä masterin Wireguard ei hyväksynyt minionin yhteydenottoja.\
Keksin pian, että minionin julkinen avain oli muuttunut välillä, ehkä vahingossa, ehkä jostain muusta syystä, mutta joka tapauksessa en valitettavavsti dokumentoinut prosessia.\
Vaihdoin julkisen avaimen masterin puolella oikeaan ja homma alkoi toimimaan:\
![wireguard-service-up-2](/assignments/H2/images/wireguard-service-up-2.png)
