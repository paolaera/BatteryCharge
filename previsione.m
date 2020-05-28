function percentCharge = previsione(energy,i,VehiclesIn,battery,maxCharge)
k = i+31;
if k > 35040
    k = 35040;
end
energy8h = sum(energy(i:k));
energyNeed = 0;
j = 1;
while VehiclesIn ~= 0
    if battery(j) == -1
        j=j+1;
    else
        energyNeed = energyNeed + maxCharge(j) - battery(j);
        VehiclesIn = VehiclesIn - 1;
        j = j+1;
    end        
end
if energyNeed <= energy8h
    percentCharge = 0;
else
    percentCharge = 8/100; 
end


