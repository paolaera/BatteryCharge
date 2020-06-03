function [battery,energy] = BatteryCharge(battery,energy,maxCharge,SOC,VehiclesIn)
      
maxCharge15min = maxChargeForStep(maxCharge,SOC);
%moltiplichiamo per 3/VehiclesIn per essere sicuri di dare un po di energia a tutte le macchine presenti,il 3 serve per non dare troppa poca carica   
    
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