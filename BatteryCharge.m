function [battery,energy] = BatteryCharge(battery,energy,maxCharge,SOC,VehiclesIn)
      
switch maxCharge
case 50
    maxCharge15min = (2.6096*10^(-12)*(SOC^8)-9.5308*10^(-10)*(SOC^7)+1.3965*10^(-7)*(SOC^6)-1.0567*10^(-5)*(SOC^5)+4.4115*10^(-4)*(SOC^4)-9.9659*10^(-3)*(SOC^3)+0.10713*(SOC^2)-0.22747*(SOC)+40.0044)*3/(4*VehiclesIn);
case 40
    maxCharge15min = (6.9094*10^(-8)*(SOC^5)-1.3526*10^(-5)*(SOC^4)+7.9866*10^(-4)*(SOC^3)-1.8297*10^(-2)*(SOC^2)+0.2762*(SOC)+40.135)*3/(4*VehiclesIn);
case 24
    maxCharge15min = (8.2535*10^(-10)*(SOC^6)-1.7954*10^(-7)*(SOC^5)+8.9088*10^(-6)*(SOC^4)+4.6377*10^(-4)*(SOC^3)-5.2636*10^(-2)*(SOC^2)+1.1144*(SOC)+39.7505)*3/(4*VehiclesIn);
end
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