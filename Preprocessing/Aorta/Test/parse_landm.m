function [where_to] = parse_landm(where_from,root_dicom,is2018)
%PARSE_LANDM Summary of this function goes here
%   Detailed explanation goes here

F=[];
fid = fopen(where_from,'r');

while ~feof(fid)
    st = fgetl(fid);
    if  contains(st,["X0","X1","X2","X3","X4"])
        stread = textscan(st,'%s %s %s %f %f %f');
        F = [F; stread{[4,5,6]}];
    end
end
fclose(fid);

% Dicom Info 
listing = dir(root_dicom);
listing_cell = struct2cell(listing);
[~, idx] = natsortfiles(listing_cell(1,:));
listing_cell_ordered = listing_cell(:,idx);
listing = cell2struct(listing_cell_ordered, fieldnames(listing), 1);
dicom_end = fullfile(listing(end).folder,listing(end).name);
dicom_start = fullfile(listing(3).folder,listing(3).name);

% Doing the Coord Change 
disp(root_dicom)
info_end = dicominfo(dicom_end);
info_start = dicominfo(dicom_start);
origin_to_use = info_end.ImagePositionPatient';
end_to_use = info_start.ImagePositionPatient';
pixel_spacing = [info_end.PixelSpacing;info_end.SpacingBetweenSlices]';

if is2018    
    disp(F);
    F = (F - origin_to_use)/pixel_spacing(1);
    F = round(F);
    F = F(:,[2 1 3]);
    disp(F);
    disp(origin_to_use);
else
    F = (F - origin_to_use)/pixel_spacing(1);
    F = round(F);
    F = F(:,[2 1 3]);
end

% Save landmarks
name = split(where_from,'\');
name = name(3);
where_to = fullfile('F:\Andrea 4Dflow\human_reproducibility_segmentation\aorta_test_data\landmarks',...
    sprintf('%s_reference_points_mimics_voxel_pos.txt',name));
fid = fopen(where_to,'wt');
for ii = 1:size(F,1)
    fprintf(fid,'%g,%g,%g\n', F(ii, 1), F(ii, 2), F(ii, 3)); %Format of txt
end
fclose(fid);
end

