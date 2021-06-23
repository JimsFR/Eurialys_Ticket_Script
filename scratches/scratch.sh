#!/bin/sh


function getName() {
  hello="Bienvenue, $nom."
  echo "$hello"
}


echo "Entrez votre nom"
read nom
getName

val=$(getName)
echo "Le mot qui sera affiché sera : $val"

until ((k == 10));
do
  let "k++"
  if ((k%2==0))
  then
    let "cpt++"
  fi
done
echo $cpt



#for ((k=0;k<=10;k++));
#do
#  echo $k
#done
