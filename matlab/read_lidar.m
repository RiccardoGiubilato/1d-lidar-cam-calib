function [scans] = read_lidar(scan_path)
    files = dir(scan_path);
    
    if length(files) > 3
		files = files(3:end);
		scans = [];
		for fid = 1 : length(files)
		    f = fopen(strcat(scan_path, files(fid).name));
		    s = fscanf(f, '%f')';
		    scans = [scans; s];
		end
	elseif length(files) == 3
		f = fopen(strcat(scan_path, files(3).name));
		    scans = fscanf(f, '%f', [1 Inf])';
	end
end

