clear
clc
load CarIO15min.txt
load PV50kWPula15min.txt
PV50kWPula15min = PV50kWPula15min';
CarIO15min(35041:end,:)=[];
CarIn = CarIO15min(:,1)';
CarOut = CarIO15min(:,2)';
Load15min = ones(size(PV50kWPula15min)); %questo valore è la potenza oraria
energy = (PV50kWPula15min - Load15min)/4;
maxCharge = [24;24;24;24;24;24;24;24;24;24];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),length(PV50kWPula15min)); %lo abbiamo inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemand15min = (zeros(size(Load15min)));
energySales15min = (zeros(size(Load15min)));
VehiclesIn = zeros(size(PV50kWPula15min)); 

for i = 1:size(energy,2)
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i)] = In(VehiclesIn(i),battery(:,i),CarIn(i),minCharge);
    end
    if CarOut(i) ~= 0
       [VehiclesIn(i),battery(:,i)] = Out(VehiclesIn(i),CarOut(i),battery(:,i));
       SOC(:,i)= SOCcontrol(battery(:,i),maxCharge);
    end
    if energy(i) < 0 %l'energia del fotovoltaico non è abbastanza
       if PV50kWPula15min(i) > 0
            for j = 1:size(battery,1)
                if battery(j,i) ~= -1
                   if SOC(j,i) < 70
                      [battery(j,i),energyDemand15min(i)] = batteryChargeRete(battery(j,i),energyDemand15min(i),-1,SOC(j,i),maxCharge(j),1);
                      SOC(j,i) = SOCcontrol(battery(j,i),maxCharge(j));
                   end
                end
            end
       end
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

energyDemand = energyDemand15min*4; %così abbiamo in kWh la vendità e la richiesta di energia
energySales = energySales15min*4;


h = figure;
MC=string(maxCharge(1));
NB=string(length(battery));
subplot(2,2,1);
plot(energyDemand(9000:10000),'c');
title('EnergyDemand')

subplot(2,2,2);
plot(energySales(9000:10000),'y');
title('EnergySales')

subplot(2,2,[3,4]);
x=9000:10000;
plot(x,Load15min(9000:10000),'b',x,PV50kWPula15min(9000:10000),'g',x,battery(:,9000:10000));
title('Load, PV and batteries')
legend({'Load','PV'},'Location','northwest','Orientation','horizontal');


filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');