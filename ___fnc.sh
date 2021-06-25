#!/bin/bash

## FONCTIONS DE CONFIGURATION ##
function __configFile() {
  _fileTemp=temp.txt    # Fichier Temporaire.
  _fileAppelsDuMois=fileAppelDuMois.txt    # Fichier comportant tout les tickets (libellé, nom client, num client, date, statut, nb de consommation par ticket).
  _fileEtatTicketsClientBrut=fileEtatTicketBrut.txt   # Fichier utilisé pour construire le fichierAllTicketRestant, il comporte (num Client, conso totale, nb ticket vendu, ticket restant et nom client).
  _fileEtatTicketsClient=fileEtatTicketEurialys.txt   # Fichier permettant de posséder tout les tickets restants de tout les clients.
  _fileClientParMois=fileClientParMois.txt   # Ce fichier renseigne tout les noms et id de clients qui ont ouvert au moins un ticket ce mois ci.
  _fileNumClient=fileNumCLient.txt # Ce fichier possède tout les num des clients une fois qu'on execute le script.
}

## FONCTIONS DE  DEBUG && ERROR ##
function __errorString() {
# src = https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
  RED='\033[0;31m'
  NC='\033[0m' # No Color

  _nomClientError="${RED}ERROR${NC}, you need to debug ${RED}'__ticketRestant'${NC} && ${RED}'__moveTo'${NC} function."
}
function __ticketRestant.Debug() {
    echo "numLigne:${_numLigne}"    # Pour cette ligne seulement de _fileClientParMois, affiche le numéro de ligne récupéré
    echo "idClient:${_idClient}"    # Pour cette ligne seulement de _fileClientParMois, affiche l’ID client
    echo "nomClient:${_nomClient1}"    # Pour cette ligne seulement de _fileClientParMois, affiche le nom du client
}

## FONCTIONS SECONDAIRES ##
function __dateAuto() {
# Affectation du jour actuel et jour précédent pour la periode avec le format (Y-M-D)
  jourActuel=$(/bin/date '+20%y-%m-%d');
  jourPrecedent=$(/bin/date --date="-1 day" '+20%y-%m-%d');

# Affectation du mois actuel et mois précédent pour la periode avec le format (Y-M-D)
  moisActuel=$(/bin/date '+20%y-%m-01');
  moisPrecedent=$(/bin/date --date="-1 month" '+20%y-%m-01'); # On prend, un mois avant

# Affectation de l'année actuel et l'année précédente pour la periode avec le format (Y-M-D)
  anneeActuelle=$(/bin/date '+20%y-01-01');
  anneePrecedente=$(/bin/date --date="-1 year" '+20%y-01-01'); # On prend, une année avant

# echo ${moisActuel} ${moisPrecedent} ${anneeActuelle} ${anneePrecedente}  # Cette commande permet le deboggage du code, n'est utile qu'en periode de TEST
}
function __formatList() {
 # Ici on remplace les '#' part des noms tel que Libellé ou bien client en les incorporant dans un fichier temporaire nommé temp.txt
 # ou nous le déplaçeront finalement avec un mv dans le fichier final $_fileAllTicket.txt...
  awk '{print gensub("#", "CLIENT:", 1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "IDTICKET:", 1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "NUMCLIENT:", 1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "TITRE:", 1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "STATUTS:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "CONSO:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "OUVERTURE:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "FERMETURE:", 1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "CONTACT1:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "CONTACT2:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "DUREE:",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  awk '{print gensub("#", "MIN",1, $0);}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  # Permet de séparer les clients...
  awk -F"NUMCLIENT|TITRE" 'BEGIN{_old=""}{if($2!=_old){_old=$2;print"=================================";print}else{print}}END{print"================================="}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
  # Remplacement des "-"
  awk 'BEGIN{FS=OFS="NUMCLIENT"}{gsub("-"," ",$1);print}' "${_fileAppelsDuMois}" > "${_fileTemp}"; mv "${_fileTemp}" "${_fileAppelsDuMois}"
}

function __retrieveTicketRestant() {
        # Initialisations
        __dateAuto

        # Début du script
        # Permet de parcourir tout©© le tableau qui est remplis des id des clients
        for i in $(cat "${_fileNumClient}"); do
                # Tant que il y a des requêtes a passer
                while read -r output; do

                        # Dans le echo j'ai mis un $3-$2, ça permet de savoir combien il y a de ticket restant.
                        # ($1 = ID Client, $2 = Somme tickets consommé, $3 = Quanité vendu, $4 = Nom du client)
                        echo "$output" | awk -F"\t" '{print $1, $2,$3, $3-$2, $4}'

                        # Au niveau de la requête SQL, il y a 3 jointures de tables qui permettent de rassembler l'ID du client, l'ID du Ticket et la sommes des tickets consommés
                        # J'ai mis dans le where = $i car a chaque tours de boucle ça change le num du client, pas besoin de les recencer, ce sera fait automatiquement dans la boucle while tout au dessus
                done< <(ssh glpistat@glpi "mysql glpi -e \"select glpi_tickets.entities_id, SUM(glpi_plugin_credit_tickets.consumed), glpi_plugin_credit_entities.quantity, SUBSTR(glpi_entities.completename, 25)
                FROM glpi_plugin_credit_tickets
                LEFT JOIN glpi_tickets ON glpi_plugin_credit_tickets.tickets_id = glpi_tickets.id
                LEFT JOIN glpi_entities ON glpi_tickets.entities_id = glpi_entities.id
                LEFT JOIN glpi_plugin_credit_entities ON glpi_tickets.entities_id = glpi_plugin_credit_entities.entities_id AND glpi_plugin_credit_tickets.plugin_credit_entities_id = glpi_plugin_credit_entities.id
                WHERE glpi_tickets.entities_id=${i}
                # la condition 'is_active=1' spécifie que le libellé de la télémaintenance doit être valide
                AND glpi_plugin_credit_entities.is_active = 1;\"" | sed 1d)

        # Permet de trier par client et renvoie dans le ${_fileEtatTicketsClientBrut} sous la forme 'data1#data2#data3#data4'
        # Ici on précise '!/NULL/' pour enlever la ligne ou toutes les données étaient nulles
        done | sort -u -t# | awk '!/NULL/' > "${_fileEtatTicketsClientBrut}"

        sed -i 's/ /#/g' "${_fileEtatTicketsClientBrut}"
}

function __setTicketRestant() {

        _client="$1"

echo "setTicketRestant: CLIENT1: ${_client}"

        # Début du script
        for _ticket in $(cat "${_fileEtatTicketsClientBrut}"); do

                # récupère les tickets restant
                _nbTicketsRestant=$(echo ${_ticket} | awk -F# '{print$4}')

                # récupère le 2ème nom du client à comparer
                _nomClient2="$(echo ${_ticket} | awk -F# '{$1=$2=$3=$4=""; print}' | sed -e 's/[- ]/#/g' | sed -e 's/####//g')"

                # Si les deux noms clients sont egaux alors on affiche les données sinon erreur.

                echo "setTicketRestant: CLIENT2: ${_nomClient2}"

                if [[ "${_client} " == "${_nomClient2} " ]]; then
                        # Construit la phrase à insérer ensuite
                        echo "DATE:" $(/bin/date '+20%y-%m-%d') "CLIENT:" ${_nomClient2} "TICKETS RESTANTS:" ${_nbTicketsRestant}
                else
                        # Cette variable ce situe dans la fonction "__ticketRestant.debug"
                        echo -e ${_nomClientError}
                fi
        # le met dans le fichier 'eurialysTickRestant.txt' lors du saut de ligne de file2 (variable : _fileEtatTicketsClient, fonction : __configFile)
        done | sort -u > "${_fileEtatTicketsClient}"
}

function __retrieveNumClient () {
        # Cette fonction écrit dans un fichier qui contiendra la liste des ID CLients.
        declare -a monTab

        while read -r nbCustomer; do
                # Debug situation == show all 'numClient'
                echo "$nbCustomer" | awk -F"\t" '{print $1}'

                # Ici j'incrémente les id des clients dans le tableau
                monTab[$nbCustomer]=$nbCustomer

        # Cette requête sql permet donc de recenser les id des clients en spécifiant qu'ils sont bien dans support
        done< <(ssh glpistat@glpi "mysql glpi -e \"SELECT id from glpi_entities where glpi_entities.completename LIKE '%support%';\"" | sed 1d > "${_fileNumClient}")
}
