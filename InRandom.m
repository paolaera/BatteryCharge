function [VehiclesIn,battery,DataVehicles] = InRandom(VehiclesIn,battery,CarIn,timeIn,DataVehicles)

muKMS= 4;
sigmaKMS= 0.5;
muTime= 8.5;
sigmaTime = 1.92;
while CarIn ~= 0
    VehiclesIn = VehiclesIn + 1;
    if battery(VehiclesIn,1) == -1
       kmsdone=lognrnd(muKMS,sigmaKMS);
       energyUsed = kmsdone*0.131;
       parkingTime=normrnd(muTime,sigmaTime);
       time15min = fix(parkingTime/0.25);
       timeOut = timeIn + time15min;
       DataVehicles(2,VehiclesIn)= timeOut;
       battery(VehiclesIn,1) = DataVehicles(1,VehiclesIn)- energyUsed;
       CarIn = CarIn - 1;
    end
end
