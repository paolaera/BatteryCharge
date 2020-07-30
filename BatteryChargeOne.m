function [battery,energy] = BatteryChargeOne(battery,energy,maxCharge,SOC)

maxCharge15min = maxChargeForStep(maxCharge,SOC);

if energy < maxCharge15min
    if battery + energy <= maxCharge
        battery = battery + energy;
        energy = 0;
    else
        battery = maxCharge;
        energy = battery + energy - maxCharge;
    end
else
    if battery + maxCharge15min <= maxCharge
        battery = battery + maxCharge15min;
        energy =  energy - maxCharge15min;
    else
        battery = maxCharge;
        energy = energy + battery - maxCharge;
    end
end
    