function [battery,energy] = BatteryDischarge(battery,energy,minCharge,maxDischarge15min)

if (battery+energy) < minCharge %l'energia richiesta non è presente nella batteria
    if (battery-minCharge) <= maxDischarge15min %l'energia richiesta non supera la costante di scarica
        energy = energy + battery - minCharge;
        battery = minCharge;                  
    else             
        energy = energy + maxDischarge15min;% tutta la scarica massima è presente nella batteria
        battery = battery - maxDischarge15min;
    end
else
    if -energy <= maxDischarge15min
       battery = battery + energy;
       energy = -0;
    else
       battery = battery - maxDischarge15min;
       energy = energy + maxDischarge15min;
    end
end
end