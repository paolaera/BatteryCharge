function [VehiclesIn,battery,DataVehicles,parkingTime] = InCar(VehiclesIn,battery,CarIn,timeIn,DataVehicles,maxCharge,yearIn,parkingTime)
k = 0;
while CarIn ~= 0
    k = k+1;
    if battery(k,1) == -1
       parkingTime(k) = yearIn(2*CarIn);
       kmsdone = yearIn(2*CarIn+1);
       energyUsed = kmsdone*0.2; %media consumo cittadino & extraurbano
       timeOut = timeIn + parkingTime(k);
       DataVehicles(2,k)= timeOut;
       battery(k,1) = maxCharge(k,1) - energyUsed;
       if battery(k,1) < 0 && battery(k,1) ~= -1
           battery(k,1) = 0;
       end
       CarIn = CarIn - 1;
       VehiclesIn = VehiclesIn + 1;
    end
end
