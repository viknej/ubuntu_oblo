F=${1:-1234} # 4 hex characters as input argument ('1234' is default)
ID=$F$F$F # 12 hex characters
SECURITY=$F$F$F$F # 16 hex characters
PROPERTIES="ohm.properties"
RTRK_CMAKE="../product/customer/rtrk/Customer.cmake"

function toggle_specific_features() {
    local state=$1
    shift
    local features=("$@")
    for feature in "${features[@]}"; do
        if [ "$state" = "ON" ]; then
            sed -i "/${feature}/s/\" OFF)/\" ON)/g" "$RTRK_CMAKE"
        else
            sed -i "/${feature}/s/\" ON)/\" OFF)/g" "$RTRK_CMAKE"
        fi
    done
}

features=(
  "ZIGBEE-BASE"
  "ZIGBEE-ZNP"
  "ZWAVE"
  #"ONVIF"
  "TUTK"
  "UPNP"
  "UPNP_SONOS"
  "HUE"
  "BROADLINK")

function create_soft_links() {
  cd ~/projects/oblo_ohm/libs/oblomessenger
  ln -s ../../../oblo_omb/libs/oblomessenger/include .
  ln -s ../../../oblo_omb/libs/oblomessenger/lib .
  cd ../..
}

function delete_bins() {
  rm -rf bins || true
}

function create_empty_enter_build() {
  if [ ! -d "build" ]; then
    mkdir "build"
  fi
  
  cd build
  rm -rf * || true
}

function cmake_make_install() {
  cmake -DCMAKE_BUILD_TYPE=Debug ..
  make -j20
  make install
}

function create_data() {
  cd ../bins
  mkdir data
}

function set_serial_security() {
  cd cfg
  sed -i "s/gtw.serial = 000000000000/gtw.serial = $ID/g" "$PROPERTIES"
  sed -i "s/gtw.security = 0000000000000000/gtw.security = $SECURITY/g" "$PROPERTIES"
}

create_soft_links
delete_bins
create_empty_enter_build
toggle_specific_features "OFF" "${features[@]}"
cmake_make_install
toggle_specific_features "ON" "${features[@]}"
create_data
set_serial_security
