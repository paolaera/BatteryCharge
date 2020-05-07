function [VehiclesIn,battery] = In(VehiclesIn,battery,CarIn,minCharge)

VehiclesIn = VehiclesIn + CarIn;
for i = 1:size(battery)
    if CarIn ~= 0
        if battery(i,1) == -1
            battery(i,1) = minCharge;
            CarIn = CarIn - 1;
        end
    end
end
    
    