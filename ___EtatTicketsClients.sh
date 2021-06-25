#!/bin/bash
source ___fnc.sh

        # Initialisation des fonctions
        __configFile
        __retrieveTicketRestant

        # Permet de rechercher dans le fichier "_fileAppelsDuMois" les "===" afin de séparer les clients
        #   et de pas tout avoir sur la même ligne. Le paramêtre "-nA1" signifie que la ligne de la donnée est écrite.

        __formatTicketRestant

        echo awk '{print gensub("#", " ",2, $0);}' "${_fileEtatTicketsRestant}";
        awk '{print gensub("#", " ",2, $0);}' "fileEtatTicketsRestant.txt";

        awk -f# 'START=$1'

