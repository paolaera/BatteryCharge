clear
clc
load PV50kWPula15min.txt
InCRS4 = readmatrix('InCRS4.txt');
InCRS4(isnan(InCRS4))= 0;
InCRS4(:,end)=[];
InCRS4(:,1)=[];
maxIn = max(InCRS4(:,1));
PV50kWPula15min = PV50kWPula15min'/4*2;%abbiamo moltiplicato per 2 per raddoppiare la produzione
Load15min = 5*ones(size(PV50kWPula15min))/4; %load a 5 kWh
energy = (PV50kWPula15min - Load15min);
A = 24*ones(30,1);
B = 40*ones(30,1);
C = 50*ones(17,1); 
maxCharge = [A;B;C];
minCharge = maxCharge/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min));%lo abbiamo inizializzato con tutte le batterie assenti
SOC = battery;
for i = 1:size(battery,2)
    SOC(:,i) = SOCcontrol(battery(:,i),maxCharge);
end

energyDemandCharge = (zeros(size(Load15min)));% energia richiesta alla rete per caricare le batterie
energyDemandLoad = (zeros(size(Load15min)));%energia richiesta alla rete per il load
energySales15min = (zeros(size(Load15min)));
VehiclesIn = zeros(size(PV50kWPula15min));
[B,I] = sortrows(SOC,1,'ascend'); %batteria meno carica prima riga, batteria più carica ultima riga
I = I';
VarCharge = I(1);
j=1;
CarIn = InCRS4(:,1)';
CarOut = zeros(size(PV50kWPula15min));
DataVehicles = [maxCharge';zeros(1,length(maxCharge'))]; % ad ogni colonna corrispondono batteria in uscita, i kms 
%percorsi e la permanenza in ricarica di ogni veicolo

for i = 1:35040
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i),DataVehicles] = InCar(VehiclesIn(i),battery(:,i),CarIn(i),i,DataVehicles,maxCharge,InCRS4(i,:));
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
    percentCharge = previsione(energy,i,VehiclesIn(i),battery(:,i),maxCharge);
    if energy(i) < 0
       energyDemandLoad(i) = - energy(i);
       for j = 1:size(battery,1)
            if battery(j,i) ~= -1
               [battery(j,i),energyDemandCharge(i)] = batteryChargeRete(battery(j,i),energyDemandCharge(i),0,SOC(j,i),maxCharge(j),percentCharge);
               SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
            end
       end
    else
           for j = 1:size(battery,1)
                if battery(j,i) ~= -1
                   energy2 = energy(i);
                   [battery(j,i),energy(i)] = BatteryCharge(battery(j,i),energy(i),maxCharge(j),SOC(j,i),VehiclesIn(i));
                   energy2 = energy2 -energy(i); % energia caricata sulla batteria
                   [battery(j,i),energyDemandCharge(i)] = batteryChargeRete(battery(j,i),energyDemandCharge(i),energy2,SOC(j,i),maxCharge(j),percentCharge);
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
PVPower = PV50kWPula15min*4;

paretoArray = energyDemandPower';
paretoArray = sortrows(paretoArray,'ascend');

%creazione delle variabili di output
Total_PV = sum(PV50kWPula15min);
Total_Load = sum(Load15min);
Total_Excess = sum(energySales15min);
Total_Electricity_into_Cover_Load = sum(energyDemandLoad);
Total_Electricity_into_Charge = sum(energyDemandCharge);
Used_PV = Total_PV - Total_Excess;
Total_Electricity_to_charge = Used_PV + Total_Electricity_into_Charge; 
PVperCent = Used_PV/Total_PV;
MaxVehicles = max(VehiclesIn);
served_Car = sum (CarIn);


%stampa a display dei risultati
fprintf('Total_PV =%f\n',Total_PV);
fprintf('Total_Load =%f\n',Total_Load);
fprintf('Total_Excess =%f\n',Total_Excess);
fprintf('Total_Electricity_into_Cover_Load =%f\n',Total_Electricity_into_Cover_Load);
fprintf('Total_Electricity_into_Charge =%f\n',Total_Electricity_into_Charge);
fprintf('Used_PV =%f\n',Used_PV);
fprintf('Total_Electricity_to_charge =%f\n',Total_Electricity_to_charge);
fprintf('PVperCent =%f\n',PVperCent);
fprintf('MaxVehicles =%d\n',MaxVehicles);
fprintf('served_Car =%d\n',served_Car);

%plot di tutti i risultati su due file
h = figure;
MC=string(maxCharge(1));
NB=string(length(I));
subplot(2,3,[2,3]);
x=21400:22400;
plot(x,energyDemandPower(21400:22400),x,energySales(21400:22400),x,PVPower(21400:22400));
legend({'energyDemand','energySales','PVPower'},'Location','northwest','Orientation','horizontal');
title('EnergyDemand,EnergySales and PV')

subplot(2,3,1);
plot(paretoArray);
title('Pareto')

%subplot(2,3,3);
%x=600:1600;
%plot(x,energySales(600:1600));
%title('EnergySales')

subplot(2,3,[4,5,6]);
x=21400:22400;
plot(x,Load15min(21400:22400),x,battery(1,21400:22400),x,battery(31,21400:22400),x,battery(61,21400:22400));
legend({'Load','24kWh','40kWh','50kWh'},'Location','northwest','Orientation','horizontal');
title('Load and batteries')

filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');
saveas(h,filename + '.fig');