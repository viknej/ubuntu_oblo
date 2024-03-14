
CLOUD=$1

OHM_PROPERTIES="/home/viktor/projects/oblo_ohm/bins/cfg/ohm.properties"
OMB_PROPERTIES="/home/viktor/projects/oblo_omb/bins/cfg/oblomb.properties"

sed -i "s/ssl\:\/\/.*/ssl\:\/\/${CLOUD}\:8884/" ${OHM_PROPERTIES}

sed -i "s/ssl\:\/\/.*/ssl\:\/\/${CLOUD}\:8884/" ${OMB_PROPERTIES}