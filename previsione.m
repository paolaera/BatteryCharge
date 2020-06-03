function percentCharge = previsione(energy,i,VehiclesIn,battery,maxCharge,parkingTime,SOC)

percentCharge = -1*ones(size(maxCharge));
k = i+31;
if k > 35040
    k = 35040;
end
energy8h = sum(energy(i:k));
energyNeed = zeros(size(maxCharge));
maxCharge15min = maxChargeForStep(maxCharge,SOC);
j = 1;
while VehiclesIn ~= 0
    if battery(j) == -1
        percentCharge(j) = -1;
        j=j+1;
    else
        energyNeed(j) = energyNeed(j) + maxCharge(j) - battery(j);
        VehiclesIn = VehiclesIn - 1;
        while battery <= maxCharge
            battery(j) = battery(j) + maxCharge15min;
            timeNeed = timeNeed +1;
        end
        if timeNeed <= parkingTime
            percentCharge = timeNeed / parkingTime;
        else
            percentCharge = 1;
        end
        j = j+1;
    end         
end

%ipotetica strategia per calcolare timeNeed
%while battery <= maxCharge
    %battery(j) = battery(j) + maxCharge15min;
    %timeNeed = timeNeed +1;
%end
%if timeNeed <= parkingTime
    %percentCharge = timeNeed / parkingTime;
%else
    %percentCharge = 1;
%end