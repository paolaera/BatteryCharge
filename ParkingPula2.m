clear
clc
load CarIO15min.txt
load PV50kWPula15min.txt
PV50kWPula15min = PV50kWPula15min';
CarIO15min(35041:end,:)=[];
CarIn = CarIO15min(:,1)';
CarOut = CarIO15min(:,2)';
Load15min = ones(size(PV50kWPula15min));
energy = (PV50kWPula15min - Load15min)/4;
maxCharge = [24;24;24;24;24;24;24;24;24;24];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min)); %lo abbiamo inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemand15min = (zeros(size(Load15min)));
energySales15min = (zeros(size(Load15min)));
[B,I] = sortrows(SOC,1,'ascend'); %batteria meno carica prima riga, batteria più carica ultima riga
I = I';
VarCharge = I(1);
j=1;
VehiclesIn = zeros(size(PV50kWPula15min)); 

for i = 1:1000
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i)] = In(VehiclesIn(i),battery(:,i),CarIn(i),minCharge);          
    end
    if CarOut(i) ~= 0
       [VehiclesIn(i),battery(:,i)] = Out(VehiclesIn(i),CarOut(i),battery(:,i));
    end
    if energy(i) < 0 %l'energia del fotovoltaico non è abbastanza
       energyDemand15min(i)= -energy(i); 
    elseif PV50kWPula15min(i) > 0
       for j = 1:size(battery,1)
            if battery(j,i) ~= -1
               energy2 = energy(i);
               [battery(j,i),energy(i)] = BatteryCharge(battery(j,i),energy(i),maxCharge(j));
               SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
               energy2 = energy2 -energy(i); % energia caricata sulla batteria
               if SOC(j,i) < 70
                  
                
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