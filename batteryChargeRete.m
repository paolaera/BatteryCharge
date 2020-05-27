function [battery,energyDemand] = batteryChargeRete(battery,energyDemand,energy2,SOC,maxCharge,percentCharge)

switch maxCharge
    case 50
        maxCharge15min = ((2.6096*10^(-12)*(SOC^8)-9.5308*10^(-10)*(SOC^7)+1.3965*10^(-7)*(SOC^6)-1.0567*10^(-5)*(SOC^5)+4.4115*10^(-4)*(SOC^4)-9.9659*10^(-3)*(SOC^3)+0.10713*(SOC^2)-0.22747*(SOC)+40.0044)*percentCharge/4) - energy2;
    case 40
        maxCharge15min = ((6.9094*10^(-8)*(SOC^5)-1.3526*10^(-5)*(SOC^4)+7.9866*10^(-4)*(SOC^3)-1.8297*10^(-2)*(SOC^2)+0.2762*(SOC)+40.135)*percentCharge/4) - energy2;
    case 24
        maxCharge15min = ((8.2535*10^(-10)*(SOC^6)-1.7954*10^(-7)*(SOC^5)+8.9088*10^(-6)*(SOC^4)+4.6377*10^(-4)*(SOC^3)-5.2636*10^(-2)*(SOC^2)+1.1144*(SOC)+39.7505)*percentCharge/4) - energy2;
end

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
