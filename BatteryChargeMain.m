clear
clc
load Load15min.txt
load PV50kWPula15min.txt
energy = (PV50kWPula15min - Load15min)'/4;
energy2 = energy;
maxCharge = [24;24;24;24];
minCharge = maxCharge/5;
battery = [(maxCharge(1)/2).*(ones(size(Load15min))');(minCharge(2)).*(ones(size(Load15min))');maxCharge(3)/4.*(ones(size(Load15min))');maxCharge(3)/3.*(ones(size(Load15min))')];%lo abbiamo inizializzato così per poter verificare se sta caricando la più scarica
energyDemand15min = (zeros(size(Load15min))');
energySales15min = (zeros(size(Load15min))');
maxCharge15min= [1.8;1.8;3.3;3.3]/4; %potenza di carica nissan leaf Slow charge 1.8 kWh, normal 3.3
maxDischarge15min = [1.8;1.8;3.3;3.3]/4; 
SOC = SOCcontrol(battery,maxCharge);
[B,I] = sortrows(SOC,1,'ascend'); %batteria meno carica prima riga, batteria più carica ultima riga
I = I';
VarCharge = I(1);
VarDischarge = I(length(I));
j=1;
for i = 9000:10000
    if energy(i) < 0 %l'energia del fotovoltaico non è abbastanza
        NumBattery=VarDischarge;
        battery(:,i+1) = battery(:,i);
        SOC(:,i+1)=SOC(:,i);
        while energy(i) < 0 & SOC(NumBattery,i)~=20 & j <= length(I)
            [battery(NumBattery,i+1),energy(i)] = BatteryDischarge(battery(NumBattery,i),energy(i),minCharge(NumBattery),maxDischarge15min(NumBattery));%applico la funzione scarica
            SOC(NumBattery,i+1) = SOCcontrol(battery(NumBattery,i+1),maxCharge(NumBattery));
            if j == size(maxCharge,1)    % usiamo questo per evitare che finisco su I(0)
                NumBattery = I(length(I)-j+1);
            else
                NumBattery = I(length(I)-j);
            end
            j=j+1;
        end
        if SOC(VarDischarge,i+1) == 20
          [B,I] = sortrows(SOC,i+1,'ascend');
          VarDischarge = I(length(I));
          VarCharge = I(1);
        end
        energyDemand15min(i)= -energy(i);
    else
        battery(:,i+1) = battery(:,i);
        SOC(:,i+1)=SOC(:,i);
        NumBattery = VarCharge;
        while energy(i) > 0 & SOC(NumBattery,i)~=100 & j <= length(I)
            [battery(NumBattery,i+1),energy(i)] = BatteryCharge(battery(NumBattery,i),energy(i),maxCharge(NumBattery),maxCharge15min(NumBattery),SOC(NumBattery,i));%applico la funzione scarica
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
    plot(energyDemand(1,9000:10000),'c');
    title('EnergyDemand')
    
    subplot(2,2,2);
    plot(energySales(1,9000:10000),'y');
    title('EnergySales')
   
    subplot(2,2,[3,4]);
    x=9000:10000;
    plot(x,Load15min(9000:10000,1),'b',x,PV50kWPula15min(9000:10000,1),'g',x,battery(:,9000:10000));
    title('Load, PV and batteries')
    
   
    filename = strcat('Plot3Apr',MC,'kWh',NB,'batteries');
    saveas(h,filename + '.jpg');
    
    
    
    fp = fopen(strcat('energyDemand',NB,'batteries','.txt'),'w');
    fp2 = fopen(strcat('energySales',NB,'batteries','.txt'),'w');
    fp3 = fopen(strcat('SOC',NB,'batteries','.txt'),'w');
    fp4 = fopen(strcat('AllData',NB,'batteries','.txt'),'w');
    
    fprintf(fp,'%f\n',energyDemand(1,9000:10000));
    fprintf(fp2,'%f\n',energySales(1,9000:10000));
    for i = 1:length(I)
        fprintf(fp3,'%s\t\t',strcat('SOC',string(i)));
    end
    for i = 9000:10000
        fprintf(fp3,'\n');
        for j = 1:length(I)
            fprintf(fp3,'%f\t',SOC(j,i));
        end
    end
    
    
  fprintf(fp4,'%s\t\t%s\t\t\t%s\t\t%s\t\t','Load','PV','Demand','Excess');
  
    for i = 1:length(I)
        fprintf(fp4,'%s\t\t',strcat('SOC',string(i)));
    end
    for i = 9000:10000
        fprintf(fp4,'\n');
        fprintf(fp4,'%f\t%f\t%f\t%f\t',Load15min(i),PV50kWPula15min(i),energyDemand(1,i),energySales(1,i));
        for j = 1:length(I)
            fprintf(fp4,'%f\t',SOC(j,i));
        end
    end
    
    
    
    fclose(fp);
    fclose(fp2);
    fclose(fp3);
    fclose(fp4);
    
       