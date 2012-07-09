#       .·'·{ RatBat script by Nbx-cmD }·'·.
# - Echoes battery state for ACPI-managed laptops -
#
#          .·'·{ Death to the rodent }·'·.

#!/bin/bash

TAM=`cat /proc/acpi/battery/BAT1/info | grep design | head -n1 |  cut -s -f11 -d" "`

# $TAM conte el tamany de la bateria // $TAM contains the battery capacity

EST=`cat /proc/acpi/battery/BAT1/state | grep remaining | cut -s -f8 -d " "`

# $EST conte la carrega restant // $EST contains the remaining battery charge

let "TPC = $EST * 100 /  $TAM"

# $TPC conte el tant per cent restant de bateria // $TPC contains the remaining battery charge percentage

PLG=`cat /proc/acpi/battery/BAT1/state | grep charging | cut -s -d " " -f 12`

# $PLG conte l'estat de carrega (charging/discharging) // $PLG contains the plug state (charging/discharging)

case "$PLG" in

	"charging" )
	PLG="^"
	;;

	"discharging" )
	PLG="v"
	;;

	* )
	PLG="?"
	;;

esac

echo "["$PLG" "$TPC" %]" 

# la sortida es del tipus [^ 45%] per a 45% i carregant o [v 45%] per a 45% i descarregant // the output looks like [^ 45%] for 45% and charging or [v 45%] for 45% and discharging.
