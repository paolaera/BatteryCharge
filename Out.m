function [VehiclesIn,battery]= Out(VehiclesIn,CarOut,battery)


while CarOut ~= 0
    VehiclesIn = VehiclesIn -1;
    [B,I] = sortrows(battery,'ascend');
    O(1) = I(end);
    I(end)=[];
    battery(O(1),1) = -1;
    CarOut = CarOut -1;
end
