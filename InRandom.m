function [VehiclesIn,battery,DataVehicles] = InRandom(VehiclesIn,battery,CarIn,timeIn,DataVehicles,maxCharge)

muKMS= 4;
sigmaKMS= 0.5;
muTime= 8.5;
sigmaTime = 1.92;
k = VehiclesIn;
while CarIn ~= 0
    k = k+1;
    if battery(k,1) == -1
       kmsdone=lognrnd(muKMS,sigmaKMS);
       energyUsed = kmsdone*0.2;
       parkingTime=normrnd(muTime,sigmaTime);
       time15min = fix(parkingTime/0.25);
       timeOut = timeIn + time15min;
       DataVehicles(2,k)= timeOut;
       battery(k,1) = maxCharge(k,1)- energyUsed;
       if battery(k,1) < 0 && battery(k,1) ~= -1
           battery(k,1) = 0;
       end
       CarIn = CarIn - 1;
       VehiclesIn = VehiclesIn + 1;
    end
end
