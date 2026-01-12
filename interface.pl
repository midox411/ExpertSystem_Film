:- use_module(library(pce)).

% Empêche les avertissements de clauses dispersées
:- discontiguous afficher_resultat/1.

% --- Fenêtre de résultat ---
afficher_resultat(FilmID) :-
    % Extraction des 11 arguments
    film(FilmID, Titre, Genres, Pays, Annee, Ambiance, Note, Realisateur, Duree, Resume, ImgPath),
    atomic_list_concat(Genres, ', ', GStr),
    
    new(D, dialog('Film Recommandé')),
    send(D, size, size(900, 500)), 

    % 1. COLONNE GAUCHE : L'IMAGE
    % On crée un groupe pour l'image pour fixer sa position
    new(ImgGroup, dialog_group(image_group)),
    (   exists_file(ImgPath) 
    ->  new(I, image(ImgPath)),
        new(Bmp, bitmap(I)),
        % On fixe la taille du bitmap directement (évite les calculs d'échelle complexes)
        send(Bmp, size, size(250, 350)), 
        send(ImgGroup, append, label(affiche, Bmp))
    ;   send(ImgGroup, append, label(noimg, 'Affiche non disponible'))
    ),
    send(D, append, ImgGroup),

    % 2. COLONNE DROITE : LES INFOS (Placées à droite du groupe image)
    new(InfoGroup, dialog_group(info_group)),
    
    % Titre principal
    send(InfoGroup, append, label(t1, Titre, font(screen, bold, 16))),
    
    % Bloc de détails
    format(atom(Details), 
           '\n~w | ~w\nRéalisateur : ~w\nNote : ~w/10 | Durée : ~w min\nGenres : ~w\nAmbiance : ~w\n\nRésumé :',
           [Annee, Pays, Realisateur, Note, Duree, GStr, Ambiance]),
    
    send(InfoGroup, append, label(t2, Details, font(screen, roman, 12))),
    
    % Résumé (Utilisation d'un label spécifique pour le texte long)
    new(Res, label(res_text, Resume)),
    send(Res, font, font(screen, roman, 11)),
    send(InfoGroup, append, Res),

    % L'astuce : On attache le groupe d'infos à DROITE du groupe image
    send(D, append, InfoGroup, right),

    % 3. BOUTON FERMER
    send(D, append, button(fermer, message(D, destroy)), below),
    
    send(D, open_centered).

% --- Prédicat Demander (Question avec image réduite) ---
demander(Message, ImagePath) :-
    new(Di, dialog('Expert Cinéma')),
    (   exists_file(ImagePath) 
    ->  new(Img, image(ImagePath)),
        new(BmpQ, bitmap(Img)),
        send(BmpQ, size, size(80, 80)),
        send(Di, append, label(img_q, BmpQ)) 
    ;   true
    ),
    send(Di, append, label(prob, Message, font(screen, bold, 12))),
    send(Di, append, button(oui, message(Di, return, oui))),
    send(Di, append, button(non, message(Di, return, non))),
    send(Di, default_button, oui),
    send(Di, open_centered),
    get(Di, confirm, Reponse),
    send(Di, destroy),
    (Reponse == oui -> assert(yes(Message)) ; assert(no(Message)), fail).

% Cas d'échec
afficher_resultat('Aucune Suggestion') :-
    send(@display, inform, 'Aucun film ne correspond à vos choix.').