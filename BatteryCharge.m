function [battery,energy] = BatteryCharge(battery,energy,maxCharge,SOC)
      
    maxCharge15min=(6.9094*10^(-8)*(SOC^5)-1.3526*10^(-5)*(SOC^4)+7.9866*10^(-4)*(SOC^3)-1.8297*10^(-2)*(SOC^2)+0.2762*(SOC)+40.135)/4;
    %funzione che carica la batteria in circa 8 ore da 20% al 100%
    
    
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