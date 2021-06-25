#!/bin/bash
source ___fnc.sh

        # Initialisation des fonctions
        __configFile
        __retrieveTicketRestant

        # Permet de rechercher dans le fichier "_fileAppelsDuMois" les "===" afin de séparer les clients
        #   et de pas tout avoir sur la même ligne. Le paramêtre "-nA1" signifie que la ligne de la donnée est écrite.

        __getTicketRestant