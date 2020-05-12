clear
clc
load PV50kWPula15min.txt
PV50kWPula15min = PV50kWPula15min';
Load15min = ones(size(PV50kWPula15min));
energy = (PV50kWPula15min - Load15min)/4;
maxCharge = [24;24;24;24;24;24;24;24;24;24];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min)); %lo abbiamo 
%inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemand15min = (zeros(size(Load15min)));
energySales15min = (zeros(size(Load15min)));
VehiclesIn = zeros(size(PV50kWPula15min));
[B,I] = sortrows(SOC,1,'ascend'); %batteria meno carica prima riga, batteria più carica ultima riga
I = I';
VarCharge = I(1);
j=1;
muIn = 9;
sigmaIn = 1.2;
r = normrnd(muIn,sigmaIn,[10,365]); %creiamo estrazioni random di ingressi 
%nei 365 giorni
yearIn = fix(r/0.25);
CarIn = zeros(size(PV50kWPula15min));
CarOut = zeros(size(PV50kWPula15min));
DataVehicles = [maxCharge';zeros(1,length(maxCharge'))]; % ad ogni colonna corrispondono batteria in uscita, i kms 
%percorsi e la permanenza in ricarica di ogni veicolo
for i= 1 : 365
    for j = 1 : size(battery,1)
        CarIn(yearIn(j,i) + (96*(i-1)))= CarIn(yearIn(j,i)+(96*(i-1)))+1;
    end
end

for i = 1:1000
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i),DataVehicles] = InRandom(VehiclesIn(i),battery(:,i),CarIn(i),i,DataVehicles);
        for j = 1 : size(battery,1)
            if DataVehicles(2,j)~=0
               CarOut(DataVehicles(2,j))= CarOut(DataVehicles(2,j))+1;
               DataVehicles(2,j)=0;
            end
        end
    end
    
    if CarOut(i) ~= 0
       [VehiclesIn(i),battery(:,i)] = Out(VehiclesIn(i),CarOut(i),battery(:,i));
       SOC(:,i)= SOCcontrol(battery(:,i),maxCharge);
    end
end
