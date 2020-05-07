function [VehiclesIn,O]= Out(VehiclesIn,CarOut,battery)

O = zeros(size(battery));
if CarOut ~= 0
    [B,I] = sortrows(battery,'ascend');
    for i = 1:CarOut
        VehiclesIn = VehiclesIn -1;
        O(i) = I(end);
        I(end)=[];
    end
end