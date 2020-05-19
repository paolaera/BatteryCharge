function converter(In)

file = fopen(In);
mat = fscanf(file,'%f %f',[2,inf]);
mat = mat';
YearIn = fopen('YearIn.txt','w');
max = 0;
for i = 1:size(mat,1)
    if mat(i,2) > max && mod(mat(i,2),1) == 0
        max = mat(i,2);
    end
end
YearIn = zeros(35040,1+2*max);



fclose(file);
fclose(YearIn);