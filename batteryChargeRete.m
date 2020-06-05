function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,batteryRemain,SOC,maxCharge,control)

if batteryRemain == -1
    maxCharge15min = control * maxChargeForStep(maxCharge,SOC);
else
    maxCharge15min = control * batteryRemain;
end


if battery + maxCharge15min < maxCharge
    battery = battery + maxCharge15min;
    energyDemand = energyDemand + maxCharge15min;
else
    energyDemand = energyDemand - battery + maxCharge;
    battery = maxCharge;
end
