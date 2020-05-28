function [VehiclesIn,battery,DataVehicles]= OutRandom(VehiclesIn,CarOut,battery,DataVehicles,SOC,maxCharge)

while CarOut ~= 0
    [B,I] = sortrows(SOC,'ascend');
    O(1) = I(end);
    I(end)=[];
    DataVehicles(1,O(1)) = battery(O(1),1); % stiamo salvando su dataVehicles la carica del veicolo in uscita
    battery(O(1),1) = -1;
    SOC(O(1),1) = SOCcontrol(battery(O(1),1),maxCharge(O(1)));
    CarOut = CarOut -1;
    VehiclesIn = VehiclesIn -1;
end
