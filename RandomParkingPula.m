clear
clc
load PV50kWPula15min.txt
PV50kWPula15min = PV50kWPula15min';
Load15min = ones(size(PV50kWPula15min))/4;
energy = (PV50kWPula15min - Load15min);
maxCharge = [24;24;24;24;24;24;24;24;24;24];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min)); %lo abbiamo 
%inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemand15min = (zeros(size(Load15min)));
energyDemandRete = (zeros(size(Load15min)));
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
       [VehiclesIn(i),battery(:,i),DataVehicles] = OutRandom(VehiclesIn(i),CarOut(i),battery(:,i),DataVehicles,SOC(:,i),maxCharge);
       SOC(:,i)= SOCcontrol(battery(:,i),maxCharge);
    end
    if energy(i) < 0 %l'energia del fotovoltaico non è abbastanza
       %if PV50kWPula15min(i) > 0
            for j = 1:size(battery,1)
                if battery(j,i) ~= -1
                   if SOC(j,i) < 70
                      [battery(j,i),energyDemand15min(i)] = batteryChargeRete(battery(j,i),energyDemand15min(i),-1,SOC(j,i),maxCharge(j),1);
                      SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
                   end
                end
            end
       %end
       energyDemand15min(i) = energyDemand15min(i) - energy(i);
    elseif PV50kWPula15min(i) > 0
       for j = 1:size(battery,1)
            if battery(j,i) ~= -1
               energy2 = energy(i);
               [battery(j,i),energy(i)] = BatteryChargeOne(battery(j,i),energy(i),maxCharge(j),SOC(j,i));
               SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
               energy2 = energy2 -energy(i); % energia caricata sulla batteria
               if SOC(j,i) < 70
                  [battery(j,i),energyDemand15min(i)] = batteryChargeRete(battery(j,i),energyDemand15min(i),0.5,SOC(j,i),maxCharge(j),0.5);
                  SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
               end 
               energySales15min(i) = energy(i);
            end   
       end
    end
    VehiclesIn(i+1)=VehiclesIn(i);
    SOC(:,i+1)=SOC(:,i);
    battery(:,i+1)= battery(:,i);  
    j=1;
end

energyDemandBattery = energyDemand15min*4; %così abbiamo in kWh la vendita e la potenza richiesta di energia
energySales = energySales15min*4;
energyDemand = energyDemandBattery + energyDemandRete;
paretoArray = energyDemand(9000:10000)';
paretoArray = sortrows(paretoArray,'ascend');

Total_PV = sum(PV50kWPula15min);
Total_Load = sum(Load15min);
Total_Excess = sum(energySales15min);
Total_Electricity_into_Cover_Load = -sum(energy(energy<0));
Total_Electricity_into_Charge = sum(energyDemandBattery);
Use_PV = Total_PV - Total_Excess;


h = figure;
MC=string(maxCharge(1));
NB=string(length(I));
x=7000:8000;
subplot(2,2,1);
plot(x,energyDemand(7000:8000));
title('EnergyDemand')

subplot(2,2,2);
plot(paretoArray);
title('Pareto')

subplot(2,2,[3,4]);
plot(x,Load15min(7000:8000),'b',x,PV50kWPula15min(7000:8000),'g',x,battery(:,7000:8000));
title('Load, PV and batteries')
legend('Load', 'PV' , 'batteries');



filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');
saveas(h,filename + '.fig');

