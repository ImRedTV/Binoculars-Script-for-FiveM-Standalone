### Documentation

#### Aperçu

Le script Binoculars permet aux joueurs d'utiliser des jumelles dans FiveM avec des fonctionnalités telles que le zoom, les modes de vision (normal, thermique et vision nocturne), et un affichage HUD personnalisable. Le script est optimisé pour les performances.
La fonctionnalité par usage d'item dans l'inventaire n'est pas garanti par manque de connaissance.

#### Fonctionnalités

- **Zoom**: Ajuster le niveau de zoom avec la molette de la souris.
- **Modes de Vision**: Passer entre les modes normal, thermique et vision nocturne.
- **HUD Personnalisé**: Afficher les informations sur le niveau de zoom et le mode de vision à l'écran.
- **Gestion des Superpositions**: Désactiver les éléments HUD par défaut tels que la mini-carte et la barre de santé lors de l'utilisation des jumelles.

#### Installation

1. **Ajouter le Script**:
   - Placez le fichier du script dans le répertoire des ressources de votre serveur.

2. **Ajouter à la Configuration du Serveur**:
   - Ajoutez `ensure red_binoculars` à votre fichier de configuration du serveur (`server.cfg`).

#### Raccourcis Clavier

- **Activer les Jumelles**: `G`
- **Ranger les Jumelles**: `Escape` et `Right Mouse Button`
- **Changer de Mode de Vision**: `SHIFT`

#### Commandes

- **/binoculars**: Basculer l'utilisation des jumelles à des fins de débogage.

#### Configuration

- **fov_max**: Champ de vision maximum (niveau de zoom).
- **fov_min**: Champ de vision minimum (niveau de zoom).
- **zoomspeed**: Vitesse de zoom avant et arrière.
- **speed_lr**: Vitesse de panoramique gauche-droite de la caméra.
- **speed_ud**: Vitesse de panoramique haut-bas de la caméra.
- **mode**: Mode de vision par défaut (0 = Normal, 1 = Thermique, 2 = Vision Nocturne).

#### Fonctions

- `ActivateBinoculars(lPed)`: Active les jumelles et démarre l'animation des jumelles.
- `DeactivateBinoculars(lPed, cam, scaleform)`: Désactive les jumelles, efface les effets et arrête l'animation.
- `DrawHUD()`: Dessine le HUD personnalisé à l'écran.
- `GetVisionMode()`: Retourne le mode de vision actuel.
- `UpdateVisionMode()`: Met à jour le mode de vision en fonction de l'option sélectionnée.
- `CheckInputRotation(cam, zoomvalue)`: Gère la rotation de la caméra en fonction de l'entrée du joueur.
- `HandleZoom(cam)`: Ajuste le niveau de zoom de la caméra.
- `HideHUDThisFrame()`: Masque les éléments HUD par défaut pendant que les jumelles sont actives.

#### Screen
[SOON]

