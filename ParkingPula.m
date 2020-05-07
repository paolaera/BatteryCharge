clear
clc
load CarIO15min.txt
load PV50kWPula15min.txt
CarIO15min(35041:end,:)=[];
CarIn = CarIO15min(:,1)';
CarOut = CarIO15min(:,2)';
Load15min = ones(size(PV50kWPula15min));
energy = (PV50kWPula15min - Load15min)'/4;
maxCharge = [24;24;24;24;24;24;24;24;24;24];
minCharge = maxCharge(1,1)/5;
battery = -1*ones(size(maxCharge,1),size(PV50kWPula15min,1)); %lo abbiamo inizializzato tutte le batterie assenti
SOC = SOCcontrol(battery,maxCharge);
energyDemand15min = (zeros(size(Load15min))');
energySales15min = (zeros(size(Load15min))');
[B,I] = sortrows(SOC,1,'ascend'); %batteria meno carica prima riga, batteria più carica ultima riga
I = I';
VarCharge = I(1);
j=1;
VehiclesIn = zeros(size(PV50kWPula15min')); 

for i = 1:1000
    if CarIn(i) ~= 0
        [VehiclesIn(i),battery(:,i)] = In(VehiclesIn(i),battery(:,i),CarIn(i),minCharge);
    end
    if CarOut(i) ~= 0
       [VehiclesIn(i),battery(:,i)] = Out(VehiclesIn(i),CarOut(i),battery(:,i));
    end
    if energy(i) < 0 %l'energia del fotovoltaico non è abbastanza
        SOC(:,i+1)=SOC(:,i);
        energyDemand15min(i)= -energy(i);
    else
        SOC(:,i+1)=SOC(:,i);
        NumBattery = VarCharge;
        while energy(i) > 0 && SOC(NumBattery,i)~=100 && j <= length(I)
            [battery(NumBattery,i+1),energy(i)] = BatteryCharge(battery(NumBattery,i),energy(i),maxCharge(NumBattery));%applico la funzione scarica
            SOC(NumBattery,i+1) = SOCcontrol(battery(NumBattery,i+1),maxCharge(NumBattery));
            if j == size(maxCharge,1)    % usiamo questo per evitare che finisco su I(size(battery)+1)
                NumBattery = I(j); 
            else
                NumBattery = I(j+1);
            end
            j=j+1;
        end
        if SOC(VarCharge,i+1) == 100
          [B,I] = sortrows(SOC,i+1,'ascend');
          VarCharge = I(1);
          VarDischarge = I(length(I));     
        end
        energySales15min(i)= energy(i);
    end
    
    j=1;
end

energyDemand = energyDemand15min*4; %così abbiamo in kWh la vendità e la richiesta di energia
energySales = energySales15min*4;


h = figure;
MC=string(maxCharge(1));
NB=string(length(I));
subplot(2,2,1);
plot(energyDemand(1,1:1000),'c');
title('EnergyDemand')

subplot(2,2,2);
plot(energySales(1,1:1000),'y');
title('EnergySales')

subplot(2,2,[3,4]);
x=1:1000;
plot(x,Load15min(1:1000,1),'b',x,PV50kWPula15min(1:1000,1),'g',x,battery(:,1:1000));
title('Load, PV and batteries')


filename = strcat('Plot1000',MC,'kWh',NB,'vehiclesPula');
saveas(h,filename + '.jpg');