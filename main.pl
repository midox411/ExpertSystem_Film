% FICHIER: main.pl
:- set_prolog_flag(encoding, utf8).
:- [base_donnees].
:- [interface].

:- dynamic yes/1, no/1.

lancer :-
    retractall(yes(_)), 
    retractall(no(_)),
    (filtrer_films(FilmID) -> 
        afficher_resultat(FilmID) 
    ;   afficher_resultat('Aucune Suggestion')).

filtrer_films(FilmID) :-
    choisir_pays(Pays),
    choisir_genre(Pays, Genre),
    % On récupère les films qui matchent Pays et Genre
    film(FilmID, _, Genres, Pays, _, Ambiance, _, _, _, _, _),
    member(Genre, Genres),
    % On demande si l'ambiance convient
    verifier(Ambiance, 'Cherchez-vous une ambiance : ', 'images/questions/ambiance.jpg'),
    !.

choisir_pays(Pays) :-
    setof(P, ID^T^G^A^Am^N^R^D^Re^I^film(ID, T, G, P, A, Am, N, R, D, Re, I), ListePays),
    member(Pays, ListePays),
    verifier(Pays, 'Voulez-vous un film de : ', 'images/questions/pays.jpg').

choisir_genre(Pays, Genre) :-
    % Extraction unique des genres pour le pays choisi
    setof(G, ID^T^An^Am^N^R^D^Re^I^Genres^(film(ID, T, Genres, Pays, An, Am, N, R, D, Re, I), member(G, Genres)), ListeGenres),
    member(Genre, ListeGenres),
    verifier(Genre, 'Aimez-vous le genre : ', 'images/questions/genre.jpg').

verifier(Valeur, Prefixe, ImgPath) :-
    atom_concat(Prefixe, Valeur, Message),
    (yes(Message) -> true ; 
     no(Message) -> fail ; 
     demander(Message, ImgPath)).