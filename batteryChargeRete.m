function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,batteryRemain,SOC,maxCharge,control)

if batteryRemain == -1
    maxCharge15min = control * maxChargeForStep(maxCharge,SOC)/9;
else
    maxCharge15min = control * batteryRemain/9; %il /3 lo stiamo mettendo per diminuire la carica dalla rete
end


if battery + maxCharge15min < maxCharge
    battery = battery + maxCharge15min;
    energyDemand = energyDemand + maxCharge15min;
else
    energyDemand = energyDemand - battery + maxCharge;
    battery = maxCharge;
end
