cd /Users/alberto
%pkg load geometry
pkg load io
cd Desktop/Batteries/

delete('OutData.txt');
delete('OutData.csv');
fileID = fopen('OutData.txt','w');
fileIID = fopen('OutData.csv','w');

%load all data file 
%these are 35040 vectors

Load  = dlmread('Load15min.txt','r');
GHI   = dlmread('GHI15min.txt','r');
PVout = dlmread('PV15min.txt','r');
%these are 35040X4 matricies, forecast at 4, 12, 24, 24 h
Loadforecast = dlmread('Loadforecast.txt','r');
GHIforecast  = dlmread('GHIforecast.txt','r');

% end load from filesep

fprintf(fileID,'t Load     PVout      SOC(kWh) unmet excess \n'); 
fprintf(fileIID,'t,Load,PVout,SOC(kWh),Mcharge,Mdischarge,unmet,excess\n'); 

scale = 0.25; % convert hourst to 15min

% initialize batteries
% parameters
Capacity_Batteries(1) = 100.0;   % kWh
Min_SOC_Batteries(1) = 0.2*Capacity_Batteries(1);   % percent
Max_SOC_Batteries(1) = 1.0*Capacity_Batteries(1);   % percent

CC(1) = 0.1*Capacity_Batteries(1); % Costant charge value (0.1 means discharge ALL the Capacity in 10 hours)
CD(1) = 0.1*Capacity_Batteries(1); % Costant discharge value

% variables
SOC_percent_Batteries(1)   = 0.5;% starting charge of the battery
SOC_kWh_Batteries(1)   =  SOC_percent_Batteries(1)*Capacity_Batteries(1);


%load all data file 
Unmet_load =0.0;
Total_load = 0.0;
Total_unmet_load = 0.0;
Total_load_served = 0.0;
Total_excess = 0.0;
    
for tstep = 9000:10000 
 
  PV_excess=  0;
  Load_served = 0.0;
  Unmet_load = 0.0;
  Excess_electricity = 0.0;
  
  if SOC_kWh_Batteries(1) >= CD + Min_SOC_Batteries(1) 
    Max_discharge_power_batteries(1) = CD;
  else
     Max_discharge_power_batteries(1) = SOC_kWh_Batteries(1) - Min_SOC_Batteries(1);
  end
  
  if SOC_kWh_Batteries(1) <= Max_SOC_Batteries(1) - CC
    Max_charge_power_batteries(1) = CC;
  else
     Max_charge_power_batteries(1) = Max_SOC_Batteries(1) - SOC_kWh_Batteries(1);
  end

  fprintf(fileID,'%d %f %f %f %f %f\n',tstep,Load(tstep),PVout(tstep),SOC_kWh_Batteries(1),Max_charge_power_batteries(1),Max_discharge_power_batteries(1)); 

  
  if PVout(tstep) >= Load(tstep) % Serve the load and Charge the Batteries
    Load_served = Load(tstep); 
    PV_excess = PVout(tstep) - Load(tstep);
    Unmet_load = 0.0;
    if PV_excess  <  Max_charge_power_batteries(1) % ALL the PV excess goes to batteries
      SOC_kWh_Batteries(1) =  SOC_kWh_Batteries(1) + scale*PV_excess;
      PV_excess=0;
    else
      SOC_kWh_Batteries(1) = SOC_kWh_Batteries(1) + scale*Max_charge_power_batteries(1);
      PV_excess = PV_excess - Max_charge_power_batteries(1) ;
      Excess_electricity = PV_excess;
    end %if PV_excess  <  Max_charge_power_batteries(1) 
    
  else   % PVout(tstep) < Load(tstep) need some batteries  
      Load_served =     PVout(tstep);
      Unmet_load = Load(tstep) - PVout(tstep); %Serve patially the load from PV
    
      if Max_discharge_power_batteries(1) > Unmet_load %charge in the battery is enough to serve the load
        SOC_kWh_Batteries(1) = SOC_kWh_Batteries(1) - scale*Unmet_load;
        Load_served = Load_served + Load(tstep);
        Unmet_load=0.0;
      else  % charge in the battery is not enough to serve the load
        Load_served = Load_served + Max_discharge_power_batteries(1);
        SOC_kWh_Batteries(1)  =  SOC_kWh_Batteries(1)-scale*Max_discharge_power_batteries(1);
        Unmet_load = Load(tstep)- Load_served;
      end
   
  end
  fprintf(fileIID,'%d  %f %f %f %f %f %f \n',tstep,Load(tstep),PVout(tstep),SOC_kWh_Batteries(1),Max_charge_power_batteries(1),Max_discharge_power_batteries(1),Unmet_load); 

  fprintf(fileID,'%d %f %f\n \n',tstep,Load_served,Unmet_load); 

  
  
   Total_load = Total_load + Load(tstep);
   Total_unmet_load = Total_unmet_load + Unmet_load;
   Total_load_served = Total_load_served + Load_served;
   Total_excess = Total_excess + Excess_electricity;
    
  
end
Total_load 
Total_unmet_load 
Total_load_served 
Total_excess 
fclose(fileIID); 
fclose(fileID); 