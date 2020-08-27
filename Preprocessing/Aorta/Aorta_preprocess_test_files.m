clear all;
clc;
first_read = 1;% Avoids accidentally overwriting files
driver_letter = 'F:';
root_filespath= strcat(driver_letter,'\Andrea 4Dflow\human_reproducibility_segmentation');
cd(root_filespath)
% Dicom images files path
filepath_test_folder = ".\testing_human_reproducibility_computed";
file_names = dir(filepath_test_folder);
file_names = file_names(3:end,:);
file_names =struct2cell(file_names);
num_files = size(file_names,2);
dicom_image_fp = ".\angio";
data_for_RL_dir = "\aorta_test_data";

%Create directory for images and landmarks
from_path_img = strcat(root_filespath,data_for_RL_dir,'\nii_images');
from_path_lm = strcat(root_filespath,data_for_RL_dir,'\landmarks');
from_path_fn = strcat(root_filespath,data_for_RL_dir,'\filenames');
to_path_img = strcat(root_filespath,data_for_RL_dir,'\images');
from_path_img_flip = strcat(root_filespath,data_for_RL_dir,'\nii_images_flip');

if ~exist(data_for_RL_dir, 'dir')
   mkdir(data_for_RL_dir)
end
if ~exist(from_path_img, 'dir')    
   mkdir(from_path_img);
end
if ~exist(to_path_img, 'dir')    
   mkdir(to_path_img);
end
if ~exist(from_path_lm, 'dir')
   mkdir(from_path_lm);
end
if ~exist(from_path_fn, 'dir')
   mkdir(from_path_fn);
end
if ~exist(from_path_img_flip, 'dir')    
   mkdir(from_path_img_flip);
end

nii_files = cell(1,num_files);
for ind_f=1:num_files
    nii_files{ind_f} = fullfile(file_names{2,ind_f},file_names{1,ind_f});
end

%% flip images to match the masks
if first_read 
    
    filepath_landm = filepath_test_folder;
    filepath_dicom = filepath_test_folder;
    
    nii_names = dir(from_path_img);
    nii_names = nii_names(3:end,:);
    nii_names =struct2cell(nii_names);
    
    from_path_masks = strcat(root_filespath,data_for_RL_dir,'\masks');
    mask_names = dir(from_path_masks);
    mask_names = mask_names(3:end,:);
    mask_names =struct2cell(mask_names);
    
    for ind_f=1:num_files
        disp(ind_f);
        %load volumes
        img_volume  = niftiread(fullfile(nii_names{2,ind_f},nii_names{1,ind_f}));
        flipped_volume = flip(img_volume,3); % required to match the mask
        fp_from_image_m = fullfile(fullfile(mask_names{2,ind_f},mask_names{1,ind_f}));
        flipped_volume_m  = niftiread(fp_from_image_m);
        %check year acq
        fp_to_year = fullfile(filepath_dicom,file_names{1,ind_f},'year_acquisition.txt');
        year_acq_file = fopen(fp_to_year);
        year_acq = textscan(year_acq_file,'%u');
        requires_flip = isequal(year_acq{1},2018);
        
        if requires_flip %if from year 2018
            % Flip image
            flipped_volume = flip(flipped_volume,1);
            flipped_volume = flip(flipped_volume,2);            
            % Flip Mask
            flipped_volume_m = flip(flipped_volume_m,1);
            flipped_volume_m = flip(flipped_volume_m,2);  
        end        
        
        %writing image
        fp_to_image = fullfile(from_path_img_flip, file_names{1,ind_f});
        niftiwrite(flipped_volume,fp_to_image) ;
        %writing mask
        [~,name_mask,~] = fileparts(mask_names{1,ind_f});
        fp_to_image = fullfile('.',data_for_RL_dir,'masks',name_mask);
        niftiwrite(flipped_volume_m,fp_to_image);
        fp_to_gz = fullfile('.',data_for_RL_dir,'masks_gz');
        gzip( fullfile('.',data_for_RL_dir,'masks',mask_names{1,ind_f}),fp_to_gz)
    end
end

%% Iterate over all images
% landmarks files path
landm_files = cell(1,num_files);
if first_read
    for i=1:num_files
        [~,landm_files{i},~] = fileparts(nii_files{i});
        % Dicom images
        fp_to_current_dicoms = fullfile(filepath_dicom,landm_files{i},'\angio\');
        % Year Acq
        fp_to_year = fullfile(filepath_dicom,landm_files{i},'year_acquisition.txt');
        year_acq_file = fopen(fp_to_year);
        year_acq = textscan(year_acq_file,'%u');
        % Landmarks
        landm_files{i} = fullfile(filepath_landm,landm_files{i},'\reference_points\reference_points_mimics.txt');
        requires_flip = isequal(year_acq{1},2018);        
        %Use where_to to write the lm_file with the landmarks
        disp(i);
        if requires_flip
            [where_to] = parse_landm(landm_files{i},fp_to_current_dicoms,requires_flip);
        else
            [where_to] = parse_landm(landm_files{i},fp_to_current_dicoms,requires_flip);
        end
    end
end

%% gzip the images
if first_read
    gzip(from_path_img_flip,to_path_img)
end
%% Create reading files (test)
cd(strcat(root_filespath,data_for_RL_dir,'\filenames'))
img_file_list = dir(to_path_img);
lm_file_list = dir(from_path_lm);

where_to = fullfile('.','AORTA_image_files_BLIND_TEST.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(img_file_list,1)
    if ~img_file_list(ii).isdir
        line_to_print = fullfile('.\\aorta_test_data\images',img_file_list(ii).name);
        line_to_print = replace(line_to_print,'\','/');
        fprintf(fid,'%s\n',line_to_print); %Format of txt
    end
end
fclose(fid);

where_to = fullfile('.','AORTA_landmark_files_BLIND_TEST.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(lm_file_list,1)
    if ~lm_file_list(ii).isdir
        line_to_print = fullfile('.\\aorta_test_data\landmarks',lm_file_list(ii).name);
        line_to_print = replace(line_to_print,'\','/');
        fprintf(fid,'%s\n',line_to_print); %Format of txt
    end
end
fclose(fid);