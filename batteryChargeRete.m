function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,energy2,SOC,maxCharge)

maxCharge15min=((6.9094*10^(-8)*(SOC^5)-1.3526*10^(-5)*(SOC^4)+7.9866*10^(-4)*(SOC^3)-1.8297*10^(-2)*(SOC^2)+0.2762*(SOC)+40.135)*20/400) - energy2;
%Calcolo del nuovo maxCharge in base a quanta energia abbiamo già messo
%nella batteria dal fotovoltaico per caricare fino al 70%
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
