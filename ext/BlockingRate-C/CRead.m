function x = CRead(filename, xsize)
fileID = fopen(filename);
x = fread(fileID, xsize, 'double');
fclose(fileID);