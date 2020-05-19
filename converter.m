function converter(In)

file = fopen(In);
mat = fscanf(file,'%f %f',[2,inf]);




fclose(file);