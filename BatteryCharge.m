function [battery,energy] = BatteryCharge(battery,energy,maxCharge,maxCharge15min)

    if (battery + energy) <= maxCharge    %l'energia prodotta ci sta nella batteria
                if energy <= maxCharge15min    %l'energia prodotta non supera la costante di carica
                   battery = battery + energy;
                   energy = 0;% tutta la carica va nella batteria
                else             
                    energy = energy - maxCharge15min;    
                    battery= battery + maxCharge15min;
                end
            else
                if energy <= maxCharge15min
                    battery = maxCharge;
                    energy = energy + battery - maxCharge;
                else
                    if battery + maxCharge15min < maxCharge
                        battery = battery + maxCharge15min;
                        energy = energy - maxCharge15min;
                    else
                        battery = maxCharge;
                        energy = energy - maxCharge + battery;
                    end
                end
    end
end