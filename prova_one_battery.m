load Load15min.txt
load PV15min.txt
PV15min=PV15min';
Load15min=Load15min';
energy = (PV15min - Load15min)/4;
maxCharge=24;
minCharge=maxCharge/5;
battery = maxCharge*ones(size(energy));
battery(1) = maxCharge/2;
energyDemand = zeros(size(energy));
energySales = zeros(size(energy));
timeCharge=21; %ore di carica
maxDischarge15min = (maxCharge- minCharge)/(timeCharge*4); %costante scarica batteria
SOC=SOCcontrol(battery,maxCharge);

% batteria nissan leaf
for i = 1:length(energy)
   if energy(i) < 0
       [battery(i),energyDemand(i)] = BatteryDischarge(battery(i),energy(i),minCharge,maxDischarge15min);
       SOC(i) = SOCcontrol(battery(i),maxCharge);
   else
       [battery(i),energySales(i)] = BatteryChargeOne(battery(i),energy(i),maxCharge,SOC(i));
       SOC(i) = SOCcontrol(battery(i),maxCharge);
   end
    if i < length(energy)
        SOC(i+1)=SOC(i);
        battery(i+1)=battery(i);
    end
end

energyDemand = -energyDemand*4; %così abbiamo in kWh la vendità e la richiesta di energia come potenza
energySales = energySales*4;

    h = figure;
    x=9000:10000;
    subplot(2,2,1);
    plot(x,energyDemand(9000:10000),'c');
    title('EnergyDemand')
    
    subplot(2,2,2);
    plot(x,energySales(9000:10000),'y');
    title('EnergySales')
   
    subplot(2,2,[3,4]);
    plot(x,Load15min(9000:10000),'b',x,PV15min(9000:10000),'g',x,battery(9000:10000));
    title('Load, PV and battery')
    legend({'Load','PV','battery'},'Location','northwest','Orientation','horizontal');    
    
