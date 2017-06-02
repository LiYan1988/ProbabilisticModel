function x = CWrite(filename, x)
fileID = fopen(filename, 'w');
fwrite(fileID, x, 'double');
fclose(fileID);