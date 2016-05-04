#!/bin/bash

echo "*** BUILDING THE APP ****************************************************************"
npm run build

echo
echo "*** DEPLOYING FILES *****************************************************************"
rsync -zvhd -e "ssh -p 3422" dist/* app@192.241.209.22:/srv/www/hobo-elm/current --delete

echo
echo "*** DONE ***"

