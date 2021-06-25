#!/bin/bash
source ___fnc.sh

  # Initialisation des fonctions
  __configFile
  __retrieveTicketRestant

  # Permet de rechercher dans le fichier "_fileAppelsDuMois" les "===" afin de séparer les clients
  #   et de pas tout avoir sur la même ligne. Le paramêtre "-nA1" signifie que la ligne de la donnée est écrite.

  __formatTicketRestant

  for _line in $(cat "${_fileFormatTicketsRestant}"); do

      # Recherche du nom du client
      _nomClient=$(echo ${_line} | awk -F# '{first = $1; $1 = ""; print $0; }')

      # Recherche du nombre de ticket restant
      _tickRestant=$(echo ${_line} | awk -F# '{first = $1; $1 = ""; print first; }')

      # Affichage des deux données rassemblées
      echo "Nom du CLient:"${_nomClient},"Ticket Restant:"${_tickRestant}
  done