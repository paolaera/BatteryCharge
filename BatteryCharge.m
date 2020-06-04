function [battery,energy] = BatteryCharge(battery,energy,maxCharge,energyPartition)
      
%maxCharge15min = maxChargeForStep(maxCharge,SOC);
%moltiplichiamo per 3/VehiclesIn per essere sicuri di dare un po di energia a tutte le macchine presenti,il 3 serve per non dare troppa poca carica   
    
    if (battery + energy) <= maxCharge    %l'energia prodotta ci sta nella batteria
                if energy <= energyPartition    %l'energia prodotta non supera la costante di carica
                   battery = battery + energy;
                   energy = 0;% tutta la carica va nella batteria
                else             
                    energy = energy - energyPartition;    
                    battery= battery + energyPartition;
                end
            else
                if energy <= energyPartition
                    battery = maxCharge;
                    energy = energy + battery - maxCharge;
                else
                    if battery + energyPartition < maxCharge
                        battery = battery + energyPartition;
                        energy = energy - energyPartition;
                    else
                        battery = maxCharge;
                        energy = energy - maxCharge + battery;
                    end
                end
    end
end