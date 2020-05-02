load Load15min.txt
load PV15min.txt
energy = (PV15min - Load15min)/4;
maxCharge=100;
minCharge =maxCharge/5;
battery = (maxCharge/2)*ones(size(Load15min));
energyDemand = zeros(size(Load15min));
energySales= zeros(size(Load15min));
timeCharge = 84; %ore caricamento nissan Leaf
maxCharge15min= (maxCharge- minCharge)/(timeCharge*4); %divisione di 21 ore in gruppi da 15min, tempo carica Nissan Leaf 
maxDischarge15min = (maxCharge- minCharge)/(timeCharge*4); %costante scarica batteria

% batteria nissan leaf
for i = 9000:10000
    if energy(i,1) < 0 %l'energia del fotovoltaico non è abbastanza
        if (battery(i,1)+energy(i,1)) < minCharge %l'energia richiesta non è presente nella batteria
            if (battery(i,1)-minCharge)<= maxDischarge15min %l'energia richiesta non supera la costante di scarica
                battery(i+1,1)= minCharge;
                energyDemand(i,1) = - energy(i,1)-battery(i,1) + minCharge;
              
            else             
                energyDemand(i,1) = - energy(i,1) - maxDischarge15min;% tutta la scarica massima è presente nella batteria
                battery(i+1,1)= battery(i,1) -maxDischarge15min;
            end
        else
            if -energy(i,1) <= maxDischarge15min
                battery(i+1,1)=battery(i,1) + energy(i,1);
            else
                battery(i+1,1)= battery(i,1) - maxDischarge15min;
                energyDemand(i,1) = - energy(i,1) -maxDischarge15min;
            end
        end
    else
        if (battery(i,1) + energy(i,1)) <= maxCharge    %l'energia prodotta ci sta nella batteria
            if energy(i,1) <= maxCharge15min    %l'energia prodotta non supera la costante di carica
                battery(i+1,1) = battery(i,1) + energy(i,1);% tutta la carica va nella batteria
            else             
                energySales(i,1) = energy(i,1) - maxCharge15min;    
                battery(i+1,1)= battery(i,1) + maxCharge15min;
            end
        else
            if energy(i,1) <= maxCharge15min
                battery(i+1,1) = maxCharge;
                energySales(i,1) = energy(i,1) + battery(i,1) - maxCharge;
            else
                if battery(i,1) + maxCharge15min < maxCharge
                    battery(i+1,1) = battery(i,1) + maxCharge15min;
                    energySales(i,1) = energy(i,1) - maxCharge15min;
                else
                    battery(i+1,1) = maxCharge;
                    energySales(i,1) = energy(i,1) - maxCharge + battery(i,1);
                end
            end
        end
    end
    SOC(i,1)=SOCcontrol(battery(i+1,1),maxCharge); %percentuale batteria
end
energyDemandTotal = sum(energyDemand(:,1));
energySalesTotal = sum(energySales(:,1));
battery(1,:)=[];

    fprintf("energia richiesta alla rete = %e\n",energyDemandTotal);
    fprintf("energia venduta = %e\n",energySalesTotal);
    
    
    h = figure;
    MC=string(maxCharge);
    subplot(2,3,1);
    plot(energyDemand(9000:10000,1),'c');
    title('EnergyDemand')
    
    subplot(2,3,2);
    plot(energySales(9000:10000,1),'y');
    title('EnergySales')
    
    subplot(2,3,3);
    plot(battery(9000:10000,1),'r');
    title(strcat('battery ',MC,'kWh'));
    
    subplot(2,3,[4,5,6]);
    x=9000:10000;
    plot(x,Load15min(9000:10000,1),'b',x,PV15min(9000:10000,1),'g');
    title('Load and PV')
    
   
    filename = strcat('Plot3Apr',MC,'kWh');
    saveas(h,filename + '.jpg');
    
