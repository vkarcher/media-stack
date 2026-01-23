# 🦅 Configuration Freebox (OS)

Pour accéder à vos services (Jellyfin, Homarr...) depuis l'extérieur de chez vous (en 4G ou chez des amis), une configuration de la Freebox est nécessaire.

## 1. Mettre le NAS en IP Fixe

Pour éviter que l'adresse IP de votre NAS change à chaque redémarrage de la box.

1. Connectez-vous à [http://mafreebox.freebox.fr/](http://mafreebox.freebox.fr/) (Double-cliquez sur "Paramètres de la Freebox").
2. Allez dans **DHCP**.
3. Onglet **Baux statiques**.
4. Cliquez sur **Ajouter un bail DHCP statique**.
5. Sélectionnez votre NAS dans la liste (cherchez "Synology" ou son adresse MAC).
6. Fixez l'IP (ex: `192.168.1.50`).
7. Validez.

## 2. Ouvrir les Ports (Redirections)

Pour autoriser le trafic internet à entrer vers votre NAS.

1. Allez dans **Gestion des ports**.
2. Cliquez sur **Ajouter une redirection**.
3. Remplissez comme suit pour chaque service :

### 🍿 Jellyfin (Pour le streaming à distance)
- **IP destination** : L'IP de votre NAS (ex: 192.168.1.50)
- **IP source** : Toutes
- **Protocole** : TCP
- **Port de début** : `8096`
- **Port de fin** : `8096`
- **Port de destination** : `8096`
- *Commentaire : Jellyfin*

### 🔍 Jellyseerr (Pour les demandes à distance)
- **IP destination** : L'IP de votre NAS
- **Protocole** : TCP
- **Port externe (début/fin)** : `5055`
- **Port interne** : `5055`
- *Commentaire : Jellyseerr Demandes*

### 🏠 Homarr (Optionnel - Pour le dashboard à distance)
- **IP destination** : L'IP de votre NAS
- **Protocole** : TCP
- **Port externe (début/fin)** : `7575`
- **Port interne** : `7575`
- *Commentaire : Homarr Dashboard*

> ⚠️ **Sécurité** : N'ouvrez JAMAIS les ports de Sonarr (`8989`), Radarr (`7878`) ou qBittorrent WebUI (`8080`) directement sur internet. Passez toujours par Homarr ou un VPN si vous devez y accéder.

## 3. Accès depuis l'extérieur

Une fois configuré, vous pouvez accéder à vos services via l'adresse IP publique de votre Freebox.

**Comment trouver mon IP publique ?** : Dans Freebox OS > État de la Freebox > État Internet > Adresse IP (IPv4).

Exemple : `http://82.xxx.xxx.xxx:8096` pour Jellyfin.

---

## 💡 Astuce : Nom de domaine (Gratuit avec Free)

Pour avoir un nom plus simple (ex: `mon-nas.freeboxos.fr`) :
1. Paramètres de la Freebox > **Nom de domaine**.
2. Activez le DNS dynamique.
3. Choisissez un sous-domaine.
4. Vous pourrez alors accéder à Jellyfin via `http://mon-nas.freeboxos.fr:8096` !
