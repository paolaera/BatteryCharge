function SOC = SOCcontrol(battery,maxCharge) %in input ha il livello delle
%batterie e le cariche massime e restituisce le percentuali di batteria
    SOC=battery*100./maxCharge;
end
