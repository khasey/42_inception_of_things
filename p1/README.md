Voici ce que nous devons faire :

1.Configurer deux machines virtuelles à l'aide de Vagrant.

2.Utiliser la dernière version stable de la distribution de notre choix comme système d'exploitation.

3.Limiter les ressources au strict minimum : 1 CPU, 512 Mo de RAM (ou 1024 Mo).

4.Les noms des machines doivent être le login de quelqu'un de ton équipe. La première machine doit être suivie de la lettre majuscule S (pour Server). La deuxième machine doit être suivie de SW (pour ServerWorker).

5.Chaque machine doit avoir une adresse IP dédiée sur l'interface eth1 : 192.168.56.110 pour la première machine (Server) et 192.168.56.111 pour la deuxième machine (ServerWorker).

6.Nous devons pouvoir nous connecter en SSH sur les deux machines sans mot de passe.

7.Installer K3s sur les deux machines : en mode contrôleur sur la première (Server) et en mode agent sur la deuxième (ServerWorker).

8.Installer kubectl et les autres outils nécessaires.
