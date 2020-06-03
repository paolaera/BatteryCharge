function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,energy2,SOC,maxCharge,percentCharge)

maxCharge15min = maxChargeForStep(maxCharge,SOC);
maxCharge15min = maxCharge15min*percentCharge - energy2;

if maxCharge15min < 0
    maxCharge15min = 0;
end
if battery + maxCharge15min < maxCharge
    battery = battery + maxCharge15min;
    energyDemand = energyDemand + maxCharge15min;
else
    energyDemand = energyDemand -battery + maxCharge;
    battery = maxCharge;
end
