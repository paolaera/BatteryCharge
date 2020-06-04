function [energyPartition,percentCharge] = previsione(energy,i,VehiclesIn,battery,maxCharge,parkingTime,SOC,OrePrevisione)

% calcolo delle iterazioni della previsione date le ore in ingresso
k = i + OrePrevisione * 4 -1; 
percentCharge = zeros(size(maxCharge));

if k > 35040
    k = 35040;
end
energy(energy<0) = 0;
energyOrePrevisione = sum(energy(i:k));
energyNeed = zeros(size(maxCharge));
timeNeed = zeros(size(maxCharge));
energyPartition = -1*ones(size(maxCharge));
control = zeros(size(maxCharge));
j = 1;
while VehiclesIn ~= 0
    if battery(j) == -1
        energyPartition(j) = 0;
        j=j+1;
    else
        energyNeed(j) = energyNeed(j) + maxCharge(j) - battery(j);
        VehiclesIn = VehiclesIn - 1;
        while battery(j) <= maxCharge(j)
            battery(j) = battery(j) + maxChargeForStep(maxCharge(j),SOC(j));
            timeNeed(j) = timeNeed(j) +1;
        end
        if timeNeed(j) > parkingTime(j)
            timeNeed(j) = parkingTime(j);
        end
        j = j+1;
    end         
end

%Distribuzione dell'energia in base alle ore di carica
timeTotal = sum(timeNeed);
for j = 1 : size(maxCharge,1)
    if energyPartition(j) ~= 0
        percentCharge(j) = 1-(timeTotal - timeNeed(j))/timeTotal;
        energyPartition(j) = energyOrePrevisione * percentCharge(j);
        energyPartition(j) = energyPartition(j)/ timeNeed(j);
    end
end


