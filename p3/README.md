Résumé des exigences de l'exercice :

    Installer K3d et Argo CD sur votre machine virtuelle.
    Créer deux namespaces :
        argocd pour Argo CD.
        dev pour l'application.
    Déployer une application dans le namespace dev en utilisant Argo CD, qui doit être automatiquement synchronisée depuis votre dépôt GitHub public.
    Avoir deux versions de l'application (v1 et v2) et être capable de passer de l'une à l'autre en modifiant le dépôt GitHub.
    Utiliser l'application de Wil (wil42/playground) ou créer votre propre application avec deux versions distinctes.
    Démontrer pendant l'évaluation que vous pouvez changer la version de l'application via le dépôt GitHub et que le changement est reflété dans votre cluster Kubernetes grâce à Argo CD.