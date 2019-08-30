function brant_write_txt(filename, txt_cell)
% input filename, csv_cell
% filename: output filename
% csv_cell: csv data stored in cell array

fid = fopen(filename, 'wb');

for m = 1:size(txt_cell, 1)
    for n = 1:size(txt_cell, 2)
        if isnumeric(txt_cell{m, n})
            tmp_cell = num2str(txt_cell{m, n});
        else
            tmp_cell = txt_cell{m, n};
        end
        if n == size(txt_cell, 2)
            fprintf(fid, '%s\n', tmp_cell);
        else
            fprintf(fid, '%s\t', tmp_cell);
        end
    end
end

fclose(fid);