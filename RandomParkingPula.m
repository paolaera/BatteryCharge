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
       [VehiclesIn(i),battery(:,i),DataVehicles] = OutRandom(VehiclesIn(i),CarOut(i),battery(:,i),DataVehicles);
       SOC(:,i)= SOCcontrol(battery(:,i),maxCharge);
    end
    if PV50kWPula15min(i) == 0 & SOC(:,i) ~= SOC(:,1)
            for j = 1:size(battery,1)
                if battery(j,i) ~= -1
                   if SOC(j,i) < 70 && SOC(j,i) > 21
                      [battery(j,i),energyDemand15min(i)] = batteryChargeRete(battery(j,i),energyDemand15min(i),energy(i));
                      SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
                   end
                end
            end   
    elseif PV50kWPula15min(i) > 0 
       for j = 1:size(battery,1)
            if battery(j,i) ~= -1
               energy2 = energy(i);
               [battery(j,i),energy(i)] = BatteryCharge(battery(j,i),energy(i),maxCharge(j));
               SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
               energy2 = energy2 -energy(i); % energia caricata sulla batteria
               if SOC(j,i) < 70 
                  [battery(j,i),energyDemand15min(i)] = batteryChargeRete(battery(j,i),energyDemand15min(i),energy2);
                  SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
                  if energyDemand15min(i) < 0
                     energySales15min(i) = -energyDemand15min(i);
                     energyDemand15min(i) = 0;
                  end
               end   
           end
       end  
    end
    VehiclesIn(i+1)=VehiclesIn(i);
    SOC(:,i+1)=SOC(:,i);
    battery(:,i+1)= battery(:,i);  
    j=1;
end

energyDemand = energyDemand15min*4; %così abbiamo in kWh la vendità e la richiesta di energia
energySales = energySales15min*4;


h = figure;
MC=string(maxCharge(1));
NB=string(length(I));
subplot(2,2,1);
plot(energyDemand(1:1000),'c');
title('EnergyDemand')

subplot(2,2,2);
plot(energySales(1:1000),'y');
title('EnergySales')

subplot(2,2,[3,4]);
x=1:1000;
plot(x,Load15min(1:1000),'b',x,PV50kWPula15min(1:1000),'g',x,battery(:,1:1000));
title('Load, PV and batteries')


filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');