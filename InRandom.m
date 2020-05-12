function [VehiclesIn,battery,timeOut] = InRandom(VehiclesIn,battery,CarIn,minCharge,timeIn)

muKMS= 4;
sigmaKMS= 0.5;
muTime= 8.5;
sigmaTime = 1.92;
while CarIn ~= 0
    VehiclesIn = VehiclesIn + 1;
    if battery(VehiclesIn,1) == -1
        battery(VehiclesIn,1) = minCharge;
        kmsdone=lognrnd(muKMS,sigmaKMS);
        energyUsed = kmsdone*0.2;
        parkingTime=normrnd(muTime,sigmaTime);
        time15min = fix(parkingTime/0.25);
        timeOut = timeIn + time15min;
        CarIn = CarIn - 1;
    end
end
