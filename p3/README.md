a finir:

```$> cat deployment.yaml | grep v1```

- image: wil42/playground:v1

```$> curl http://localhost:8888/```

{"status":"ok", "message": "v1"}

```$>sed -i 's/wil42\/playground\:v1/wil42\/playground\:v2/g' deploy.yaml```

```$>g up "v2" # git add+commit+push```

[..]
a773f39..999b9fe master -> master

```$> cat deployment.yaml | grep v2```

- image: wil42/playground:v2
et donc si ca marche bien le push on devra faire ca 
```$> curl http://localhost:8888/```
{"status":"ok", "message": "v2"}
et si la reponse est bonne on a fini

Résumé des exigences de l'exercice :

    Installer K3d et Argo CD sur votre machine virtuelle.
    Créer deux namespaces :
        argocd pour Argo CD.
        dev pour l'application.
    Déployer une application dans le namespace dev en utilisant Argo CD, qui doit être automatiquement synchronisée depuis votre dépôt GitHub public.
    Avoir deux versions de l'application (v1 et v2) et être capable de passer de l'une à l'autre en modifiant le dépôt GitHub.
    Utiliser l'application de Wil (wil42/playground) ou créer votre propre application avec deux versions distinctes.
    Démontrer pendant l'évaluation que vous pouvez changer la version de l'application via le dépôt GitHub et que le changement est reflété dans votre cluster Kubernetes grâce à Argo CD.
