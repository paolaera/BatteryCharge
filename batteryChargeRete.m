function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,energy2)

maxCharge15min=((-0.0002*(battery^4)+0.0083*(battery^3)-0.12*(battery^2)+0.74*(battery)+2.9765)*30/400) - energy2;
%Calcolo del nuovo maxCharge in base a quanta energia abbiamo già messo
%nella batteria dal fotovoltaico per caricare fino al 70%
if maxCharge15min < 0
    maxCharge15min = 0;
end
battery = battery + maxCharge15min;
energyDemand = energyDemand + maxCharge15min;