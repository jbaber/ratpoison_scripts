#!/bin/bash

#======================================================
# RatCPI version .10--Power management, Ratpoison style
# By Door
#======================================================

## Do you want to be informed of charging status?
##   This is distinct from "losing power" status.
## 0=no, 1=yes
informcharged=1

## How long to wait before in between checks.
## Default:  2 minutes (120 seconds)
delay=120

## Various important variables
plugged=$(eval acpi -V|grep off-line|wc -l)
charging=$(eval acpi -V|grep charging|wc -l)
never=$(eval acpi -V|grep never|wc -l)
battlevel=$(eval acpi)

if (($plugged==1))
then
eval 'ratpoison -c "echo $battlevel"'

elif (($charging==1))
then
eval 'ratpoison -c "echo $battlevel"'

else
echo $battlevel > /dev/null
fi

while winsys=$(ps -e | grep ratpoison | wc -l)
        [ "$winsys" != 0 ]
        do

        charge=$(eval acpi -V|grep charge|wc -l)
        never2=$(eval acpi -V|grep never|wc -l)

        lowbatt50=$(eval acpi|grep 50%|wc -l)
        lowbatt25=$(eval acpi|grep 25%|wc -l)
        lowbatt15=$(eval acpi|grep 15%|wc -l)
        lowbatt10=$(eval acpi|grep 10%|wc -l)
        lowbatt5=$(eval acpi|grep \ 5%|wc -l)
        lowbatt3=$(eval acpi|grep \ 3%|wc -l)
        lowbatt1=$(eval acpi|grep \ 1%|wc -l)

        hibat99=$(eval acpi|grep 99%|wc -l)
        hibat75=$(eval acpi|grep 75%|wc -l)

if (($charge==1))
   then

   if (($informcharged==0))
      then
      continue

   elif (($never2==1))
      then
	     echo $lowbatt50 > /dev/null

   elif (($hibat99==1))
	     then
	     eval 'ratpoison -c "echo Battery charged to 99%"'

   elif (($hibat75==1))
	     then
	     eval 'ratpoison -c "echo Battery charged to 75%"'

   elif (($lowbatt50==1))
	     then
	     eval 'ratpoison -c "echo Battery charged to 50%"'

   elif (($lowbatt25==1))
	     then
	     eval 'ratpoison -c "echo Battery charged to 25%"'

   elif (($lowbatt10==1))
	     then
	     eval 'ratpoison -c "echo Battery charged to 10%"'

   fi

fi

if (($charge==0))
   then

   if (($hibat99==1))
	     then
	     eval 'ratpoison -c "echo Battery at 99%"'

   elif (($hibat75==1))
	     then 
	     eval 'ratpoison -c "echo Battery at 75%"'

   elif (($lowbatt50==1))
	     then
	     eval 'ratpoison -c "echo Battery at 50%"'

   elif (($lowbatt25==1))
	     then 
	     eval 'ratpoison -c "echo Battery at 25%"'

   elif (($lowbatt15==1))
	     then
	     eval 'ratpoison -c "echo Battery at 15%"'

   elif (($lowbatt10==1))
	     then
	     eval 'ratpoison -c "echo Battery at 10%"'

   elif (($lowbatt5==1))
	     then
	     eval 'ratpoison -c "echo Battery at 5%!"'

   elif (($lowbatt3==1))
	     then
	     eval 'ratpoison -c "echo Battery at 3%!"'

   elif (($lowbatt1==1))
	     then
	     eval 'ratpoison -c "echo The battery is at 1%! Plug it in or turn it off!"'
   fi

fi

sleep $delay
done
