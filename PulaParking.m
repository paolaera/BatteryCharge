clear
clc
load PV50kWPula15min.txt
PV50kWPula15min = PV50kWPula15min';
Load15min = ones(size(PV50kWPula15min))/4;
energy = (PV50kWPula15min - Load15min);
maxCharge = [40;40;40;40;40;40;40;40;40;40];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min)); %lo abbiamo 
%inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemandCharge = (zeros(size(Load15min)));% energia richiesta alla rete per caricare le batterie
energyDemandLoad = (zeros(size(Load15min)));%energia richiesta alla rete per il load
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

for i = 1:35040
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i),DataVehicles] = InRandom(VehiclesIn(i),battery(:,i),CarIn(i),i,DataVehicles,maxCharge);
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
    if energy(i) < 0
       energyDemandLoad(i) = - energy(i);
       for j = 1:size(battery,1)
            if battery(j,i) ~= -1
               [battery(j,i),energyDemandCharge(i)] = batteryChargeRete(battery(j,i),energyDemandCharge(i),energy(i));
               SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
            end
       end
    else
           for j = 1:size(battery,1)
                if battery(j,i) ~= -1
                   energy2 = energy(i);
                   [battery(j,i),energy(i)] = BatteryCharge(battery(j,i),energy(i),maxCharge(j));
                   energy2 = energy2 -energy(i); % energia caricata sulla batteria
                   [battery(j,i),energyDemandCharge(i)] = batteryChargeRete(battery(j,i),energyDemandCharge(i),energy2);
                   SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
                end
           end  
           energySales15min(i) = energy(i);
    end
    VehiclesIn(i+1)=VehiclesIn(i);
    SOC(:,i+1)=SOC(:,i);
    battery(:,i+1)= battery(:,i);  
    j=1;
end

energyDemandPower = (energyDemandCharge + energyDemandLoad)*4; %così abbiamo in kWh la vendita e la potenza richiesta di energia
energySales = energySales15min*4;
paretoArray = energyDemandPower';
paretoArray = sortrows(paretoArray,'ascend');

h = figure;
MC=string(maxCharge(1));
NB=string(length(I));
subplot(2,2,1);
plot(energyDemandPower(1:1000),'c');
title('EnergyDemandPower')

subplot(2,2,2);
plot(paretoArray);
title('Pareto')

subplot(2,2,[3,4]);
x=1:1000;
plot(x,Load15min(1:1000),'b',x,PV50kWPula15min(1:1000),'g',x,battery(:,1:1000));
title('Load, PV and batteries')


filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');
saveas(h,filename + '.fig');