function [battery,energySales,chargeRemain] = BatteryCharge(battery,energy,maxCharge,percentCharge,energySales,SOC)

maxCharge15minPV = energy * percentCharge;     
maxCharge15min = maxChargeForStep(maxCharge,SOC);
if maxCharge15minPV < maxCharge15min
    chargeRemain = maxCharge15min - maxCharge15minPV;
    maxCharge15min = maxCharge15minPV;
    energySales = 0;
else
    energySales = energySales + maxCharge15minPV - maxCharge15min;
    chargeRemain = 0;
end

if (battery + maxCharge15min) <= maxCharge    %l'energia prodotta ci sta nella batteria
    battery = battery + maxCharge15min;
else 
    battery = maxCharge;
end
                
                
                
                
                
                
                
                
                
                
                
               
