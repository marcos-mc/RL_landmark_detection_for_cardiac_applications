clear all;
clc;
cd('F:\TFM\Data\Andrea 4Dflow')
addpath(".\NIfTI_tools")% Nifti visualizing package
first_read = 0;% Avoids accidentally overwriting files

%% images files path
filepath_img = ".\MyData\0_Images\";
in_path = filepath_img + "images_nii.gz\*.gz";
out_path = filepath_img + "images_nii\";

file_names = dir(out_path+'*.nii');
file_names =struct2cell(file_names);
num_files = size(file_names,2);

% Loading nii_files
if ~exist(out_path, 'dir')
    nii_files = gunzip(in_path,out_path); % nii path
else
    nii_files = cell(1,num_files);
    for ind_f=1:num_files
        nii_files{ind_f} = fullfile(file_names{2,ind_f},file_names{1,ind_f});
    end
end
%% flip images to match the masks
if first_read
    flipped_img_dir = 'F:\TFM\Data\Andrea 4Dflow\MyData\Images\images_nii_flip';
    %Unzips the nii.gz files
    for ind_f=1:num_files
        disp(ind_f);
        img_volume  = niftiread(nii_files{ind_f});
        flipped_volume = flip(img_volume,3);
        fp_to_image = fullfile(flipped_img_dir, file_names{1,ind_f});
        niftiwrite(flipped_volume,fp_to_image) ;
    end
end
%% flip images that were wrongly flipped
if first_read
    cd('C:\Users\Marcos\Desktop\Nueva carpeta (2)')
    
    img_list_img = dir();
    %Unzips the nii.gz files
    for ind=1:length(img_list_img)
        if ~img_list_img(ind).isdir
            fp_from_image = fullfile(img_list_img(ind).folder, img_list_img(ind).name);
            img_volume  = niftiread(fp_from_image);
            flipped_volume = flip(img_volume,1);
            flipped_volume = flip(flipped_volume,2);
            fp_to_image = fullfile(img_list_img(ind).folder,'Flipped\Image' ,img_list_img(ind).name);
            niftiwrite(flipped_volume,fp_to_image);
        end
    end
    img_list_mask = dir('.\mask');
    for ind=1:length(img_list_mask)
        if ~img_list_mask(ind).isdir
            fp_from_image = fullfile(img_list_mask(ind).folder, img_list_mask(ind).name);
            img_volume  = niftiread(fp_from_image);
            flipped_volume = flip(img_volume,1);
            flipped_volume = flip(flipped_volume,2);
            [~,file_name,~] = fileparts(img_list_mask(ind).name);
            
            fp_to_image = fullfile(img_list_img(ind).folder,'Flipped\Mask' ,file_name);
            niftiwrite(flipped_volume,fp_to_image);
            fp_to_gz = fullfile(img_list_img(ind).folder,'Flipped\Mask_gz');
            gzip(fp_to_image,fp_to_gz)
        end
    end
end
%% landmarks files path
landm_files = cell(1,num_files);
filepath_landm = ".\MyData\";
filepath_dicom = ".\training\";

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
        landm_files{i} = fullfile(filepath_landm,landm_files{i},'reference_points_mimics.txt');
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
    from_path_img = "F:\TFM\Data\Andrea 4Dflow\MyData\0_Images\images_nii_flip";
    to_path = "F:\TFM\Data\Andrea 4Dflow\finaldata\training\images";
    gzip(from_path_img,to_path)
end
%% Visualization (needs rework)
image_ind = 1;
%current_path = landm_files{image_ind};
%fileID = fopen(current_path);
%data = textscan(fileID,'%u %u %u','Delimiter',',');
image= nii_files{image_ind};
nii = load_nii(image);
k = 1;
%option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
option.setcolorindex = 3;
view_nii(nii,option);
h = gcf;
kmax = 5;%size(data{1},1);

while 1
    try
        was_a_key = waitforbuttonpress;
    catch exception % avoids error when the window is clossed
        break
    end
    
    if was_a_key && strcmp(get(h, 'CurrentKey'), 'rightarrow')
        k = min(k + 1,kmax); %Decreases the landmark
        %option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
        view_nii(h,nii,option);
        
    elseif was_a_key && strcmp(get(h, 'CurrentKey'), 'leftarrow')
        k = max(1, k - 1); %Decreases the landmark
        %option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
        view_nii(h,nii,option);
    end
end
%% Randomize 
p=0.30;
idx=randperm(num_files);
samples_testing = round(p*num_files);
testing_ind = idx(1:samples_testing) ;
training_ind = idx(samples_testing+1:end);

close all
histogram(Testing,'FaceColor','b','FaceAlpha',0.4,'Normalization' , 'probability')
hold on
histogram(Training,'FaceColor','g','FaceAlpha',0.4,'Normalization' , 'probability')
legend({'Test','Train'})

%% Move files

if first_read
    clc
    load testing_ind.mat testing_ind
    from_path_img = 'F:\TFM\Data\Andrea 4Dflow\finaldata\training\images';
    from_path_lm = 'F:\TFM\Data\Andrea 4Dflow\finaldata\training\landmarks';
    
    file_list = dir(from_path_img);
    landmarks_path = 'F:\TFM\Data\Andrea 4Dflow\finaldata\test\landmarks';
    image_path = 'F:\TFM\Data\Andrea 4Dflow\finaldata\test\images';
    
    for i=1:length(testing_ind)
        name = file_list(testing_ind(i)+2).name;
        file_path_img =fullfile(from_path_img,name);
        
        disp(['moving: ', file_path_img]);
        disp(['-->to: ',image_path])
        movefile(file_path_img, image_path)
        lm_name = split(name,'.');
        landmark_name =  sprintf('%s_reference_points_mimics_voxel_pos.txt',lm_name{1});
        file_path_lm = fullfile(from_path_lm,landmark_name);
        disp(['moving: ', file_path_lm]);
        disp(['-->to: ',landmarks_path])
        movefile(file_path_lm, landmarks_path)
    end
    
    disp( [ 'number of testing images = ',int2str(length(dir(image_path))-2)]);
    disp( [ 'number of testing landmarks = ',int2str(length(dir(landmarks_path))-2)]);
    disp( [ 'number of training images = ',int2str(length(dir(from_path_img))-2)]);
    disp( [ 'number of training landmarks = ',int2str(length(dir(from_path_lm))-2)]);
end

%% Create reading files (Train)
cd('F:\TFM\Data\Andrea 4Dflow\finaldata\training\filenames')

from_path_img = 'F:\TFM\Data\Andrea 4Dflow\finaldata\training\images';
from_path_lm = 'F:\TFM\Data\Andrea 4Dflow\finaldata\training\landmarks';

img_file_list = dir(from_path_img);
lm_file_list = dir(from_path_lm);

where_to = fullfile('.','AORTA_image_files.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(img_file_list,1)
    if ~img_file_list(ii).isdir
        fprintf(fid,'%s\n',fullfile('.\\finaldata\training\images',img_file_list(ii).name)); %Format of txt
    end
end
fclose(fid);

where_to = fullfile('.','AORTA_landmark_files.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(lm_file_list,1)
    if ~lm_file_list(ii).isdir
        fprintf(fid,'%s\n',fullfile('.\\finaldata\training\landmarks',lm_file_list(ii).name)); %Format of txt
    end
end
fclose(fid);

%% Create reading files (Validation)

cd('F:\TFM\Data\Andrea 4Dflow\finaldata\test\filenames')

from_path_img = 'F:\TFM\Data\Andrea 4Dflow\finaldata\test\images';
from_path_lm = 'F:\TFM\Data\Andrea 4Dflow\finaldata\test\landmarks';

img_file_list = dir(from_path_img);
lm_file_list = dir(from_path_lm);

where_to = fullfile('.','AORTA_image_files_TEST.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(img_file_list,1)
    if ~img_file_list(ii).isdir
        fprintf(fid,'%s\n',fullfile('.\\finaldata\test\images',img_file_list(ii).name)); %Format of txt
    end
end
fclose(fid);

where_to = fullfile('.','AORTA_landmark_files_TEST.txt');
fid = fopen(where_to,'wt');
for ii = 1:size(lm_file_list,1)
    if ~lm_file_list(ii).isdir
        fprintf(fid,'%s\n',fullfile('.\\finaldata\test\landmarks',lm_file_list(ii).name)); %Format of txt
    end
end
fclose(fid);
