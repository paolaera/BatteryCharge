function [VehiclesIn,battery] = In(VehiclesIn,battery,CarIn,minCharge)

while CarIn ~= 0
    VehiclesIn = VehiclesIn + 1;
    if battery(VehiclesIn,1) == -1
        battery(VehiclesIn,1) = minCharge;
        CarIn = CarIn - 1;
    end
end

    
    