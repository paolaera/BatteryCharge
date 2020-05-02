load Load15min.txt
load PV15min.txt
energy = (PV15min - Load15min)/4;
maxCharge=24;
minCharge =maxCharge/5;
battery(1,1) = maxCharge/2;
energyDemand = 0;
energySales = 0;
timeCharge = 21; %ore caricamento nissan Leaf
maxCharge15min= (maxCharge- minCharge)/(timeCharge*4); %divisione di 21 ore in gruppi da 15min, tempo carica Nissan Leaf 
maxDischarge15min = (maxCharge- minCharge)/(timeCharge*4); %costante scarica batteria

% batteria nissan leaf
for i = 1:size(energy,1)
    if energy(i,1) < 0 %l'energia del fotovoltaico non è abbastanza
        if (battery(i,1)+energy(i,1)) < minCharge %l'energia richiesta non è presente nella batteria
            if (battery(i,1)-minCharge)<= maxDischarge15min %l'energia richiesta non supera la costante di scarica
                battery(i+1,1)= minCharge;
                batteria=battery(i+1,1);
                energyDemand = energyDemand - energy(i,1)-battery(i,1) + minCharge;
            else             
                energyDemand = energyDemand - energy(i,1) - maxDischarge15min;% tutta la scarica massima è presente nella batteria
                battery(i+1,1)= battery(i,1) -maxDischarge15min;
                batteria=battery(i+1,1);
            end
        else
            if -energy(i,1) <= maxDischarge15min
                battery(i+1,1)=battery(i,1) + energy(i,1);
                batteria=battery(i+1,1);
            else
                battery(i+1,1)= battery(i,1) - maxDischarge15min;
                energyDemand = energyDemand - energy(i,1) -maxDischarge15min;
                batteria=battery(i+1,1);
            end
        end
    else
        if (battery(i,1) + energy(i,1)) <= maxCharge    %l'energia prodotta ci sta nella batteria
            if energy(i,1) <= maxCharge15min    %l'energia prodotta non supera la costante di carica
                battery(i+1,1) = battery(i,1) + energy(i,1);% tutta la carica va nella batteria
                batteria=battery(i+1,1);

            else             
                energySales = energySales + energy(i,1) - maxCharge15min;    
                battery(i+1,1)= battery(i,1) + maxCharge15min;
                batteria=battery(i+1,1);
            end
        else
            if energy(i,1) <= maxCharge15min
                battery(i+1,1) = maxCharge;
                energySales = energySales + energy(i,1) + battery(i,1) - maxCharge;
                batteria=battery(i+1,1);
            else
                if battery(i,1) + maxCharge15min < maxCharge
                    battery(i+1,1) = battery(i,1) + maxCharge15min;
                    batteria=battery(i+1,1);
                    energySales = energySales + energy(i,1) - maxCharge15min;
                else
                    battery(i+1,1) = maxCharge;
                    batteria=battery(i+1,1);
                    energySales = energySales + energy(i,1) - maxCharge + battery(i,1);
                end
            end
        end
    end
    SOC(i,1)=SOCcontrol(battery(i+1,1),maxCharge); %percentuale batteria
end
battery(1,:)=[];

    fprintf("energia richiesta alla rete = %e\n",energyDemand);
    fprintf("energia venduta = %e\n",energySales);
    subplot(2,3,1);
    plot(Load15min,'b');
    title('Subplot 1: Load15min')
    
    subplot(2,3,2);
    plot(PV15min,'g');
    title('Subplot 2: PV15min')
    
    subplot(2,3,3);
    plot(battery,'r');
    title('Subplot 3: battery')
    
    subplot(2,3,[4,5,6]);
    x=1:size(Load15min,1);
    plot(x,Load15min,'b',x,PV15min,'g',x,battery,'r');
    title('Subplot all')
    
     MC=string(maxCharge);
    filename = strcat('PlotTotale',MC,'kWh');
    savefig(filename)
    
