function [VehiclesIn,battery]= Out(VehiclesIn,CarOut,battery)

VehiclesIn = VehiclesIn -CarOut;
if CarOut ~= 0
    [B,I] = sortrows(battery,'ascend');
    for i = 1:CarOut
        O(i) = I(end);
        I(end)=[];
        battery(O(i),1) = -1;
    end
end
