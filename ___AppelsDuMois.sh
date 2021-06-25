#!/bin/bash
source ___fnc.sh

## FONCTION PRINCIPALE ##
function __allTicket(){
# On appelle les deux fonctions dans le but d'intialiser les variables
  __dateAuto
  __configFile
  __retrieveNumClient

  # Permet de parcourir tout©© le tableau qui est remplis des id des clients
  for k in $(cat "${_fileNumClient}"); do
      while read -r output; do
        # Dans le echo j'ai mis un $10/60, ça permet de passer le "datetime" qui est secondes en  minutes
        echo "$output" | awk -F"\t" '{print "#", $11, "#", $1, "#", $2, "#", $3, "#", $4, "#", $5, "#", $6, "#", $7, "#", $8, "#", $9, "#" ,$10/60, "#"}'

      # Au niveau de la requête SQL, il y a 3 jointures de tables qui permettent de rassembler les emails, les entreprises et le nom des entreprises
       # J'ai mis dans le where = $k car a chaque tours de boucle ça change le num du client, pas besoin de les recencer, ce sera fait automatiquement dans la boucle while tout au dessus
        done< <(ssh glpistat@glpi "mysql glpi -e \"SELECT glpi_tickets.id, glpi_entities.id, glpi_tickets.name,glpi_tickets.status, glpi_plugin_credit_tickets.consumed ,glpi_tickets.date,
        glpi_tickets.closedate,glpi_useremails.email, glpi_tickets_users.alternative_email, glpi_tickets.actiontime AS 'duree :', SUBSTR(glpi_entities.completename, 25)
      FROM glpi_tickets
      LEFT JOIN glpi_tickets_users ON glpi_tickets.id = glpi_tickets_users.tickets_id
      LEFT JOIN glpi_useremails ON glpi_tickets_users.users_id = glpi_useremails.users_id
      LEFT JOIN glpi_entities ON glpi_tickets.entities_id = glpi_entities.id
      LEFT JOIN glpi_plugin_credit_tickets ON glpi_tickets.id = glpi_plugin_credit_tickets.tickets_id
     LEFT JOIN glpi_plugin_credit_entities ON glpi_tickets.entities_id = glpi_plugin_credit_entities.entities_id
      WHERE glpi_tickets.entities_id = ${k}
        AND glpi_entities.completename LIKE '%support%'
        AND glpi_tickets.date >= '${moisPrecedent}'
        AND glpi_tickets.date <= '${moisActuel}'
      ORDER BY SUBSTR(glpi_entities.completename,25);\"" | sed 1d)

  # Trie client par client et renvoie dans le "${_fileAllTicket}" (variable : _fileAllTicket, fonction : __configFile)
  done | sort -u -t# > "${_fileAllTicket}"

  __formatList
}
__allTicket
