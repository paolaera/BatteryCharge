function YearIn = converter(In)

file = fopen(In);
mat = fscanf(file,'%f %f',[2,inf]);
mat = mat';
max = 0;
for i = 1:size(mat,1)
    if mat(i,2) > max && mod(mat(i,2),1) == 0
        max = mat(i,2);
    end
end
TimeAndKm=zeros(size(mat,1),2);
YearIn = zeros(35040,1+2*max);
AutoIn = zeros(size(mat,1),2);
for i = 1 : size(mat,1)
    if mod(mat(i,1),1) ~= 0
        TimeAndKm(i,:) = mat(i,:);
    else
        AutoIn(i,:) = mat(i,:);
    end   
end

for i= 1:size(AutoIn,1)
    if AutoIn(i,1) ~= 0
       YearIn(AutoIn(i,1),1) = AutoIn(i,2);
    end
    buffer = AutoIn(i,2);
    while buffer ~= 0
        for j = 2:1+2*buffer
            if YearIn(AutoIn(i,1),j) == 0
                YearIn(AutoIn(i,1),j) = TimeAndKm(i+buffer,1);
                YearIn(AutoIn(i,1),j+1) = TimeAndKm(i+buffer,2)*2; % i dati in ingresso sono one-way
                buffer= buffer -1;
            end
        end
        
    end
end



fclose(file);
