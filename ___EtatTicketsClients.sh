#!/bin/bash
source ___fnc.sh

        # Initialisation des fonctions
        __configFile
        __retrieveTicketRestant

        # Permet de rechercher dans le fichier "_fileAppelsDuMois" les "===" afin de séparer les clients
        #   et de pas tout avoir sur la même ligne. Le paramêtre "-nA1" signifie que la ligne de la donnée est écrite.

        grep -nA1 "===" "${_fileAppelsDuMois}"| awk -F"CLIENT: | IDTICKET|NUMCLIENT: | TITRE" 'BEGIN{OFS="NUMCLIENT"}{if(NF>1){gsub("-","#",$2);gsub(" ","#",$2);print(substr($1,0,length($1)-1))"_"$4"_"$2}}' > "${_fileClientParMois}"

        # Pour chaque ligne de _fileClientParMois

        for _ligne in $(cat "${_fileClientParMois}"); do
                _numLigne=$(echo ${_ligne} | awk -F_ '{print$1}')     # récupère le numéro de ligne
                _nomClient1="$(echo ${_ligne} | awk -F_ '{$1=$2=""; print}')"    # récupère le 1er nom du client à comparer

                echo "**${_nomClient1}"

                #  __EtatTicketsClients.Debug   # mode debug

                __setTicketRestant "${_nomClient1}"  # Permet de d'afficher l'affichage de tout les clients des tickets restants

        done  # Passe à la ligne suivante du fichier "_fileClientParMois"
