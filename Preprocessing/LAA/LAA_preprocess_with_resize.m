clear;
clc;
driver_letter = 'F:';
root_filespath= strcat(driver_letter,'\TFM\Data\LAA');
cd(root_filespath)

bordeaux_img_raw_dir = strcat(root_filespath,'\LAA_Bordeaux_resampled');
denmark_img_raw_dir = strcat(root_filespath,'\LAA_Denmark_resampled');

% Read filenames
denmark_names = dir(denmark_img_raw_dir);
denmark_names = denmark_names(3:end,:);
bordeaux_names = dir(bordeaux_img_raw_dir);
bordeaux_names = bordeaux_names(3:end,:);


% Denmark
for ind_img = 1:length(denmark_names)
    image_folder_filepath = fullfile(denmark_names(ind_img).folder,denmark_names(ind_img).name,'\image');
    nii_file_path = fullfile(image_folder_filepath,'image.nii');
    if ~exist(nii_file_path, 'file')
        disp(['Decompressing: ', denmark_names(ind_img).name])
        gunzip(image_folder_filepath);
    end
    info = niftiinfo(nii_file_path);
    denmark_names(ind_img).ImageSize = info.ImageSize;
    denmark_names(ind_img).ImageSize_x = info.ImageSize(1);
    denmark_names(ind_img).ImageSize_y = info.ImageSize(2);
    denmark_names(ind_img).ImageSize_z = info.ImageSize(3);
    
    denmark_names(ind_img).PixelDimensions_x = info.PixelDimensions(1);
    denmark_names(ind_img).PixelDimensions_y = info.PixelDimensions(2);
    denmark_names(ind_img).PixelDimensions_z = info.PixelDimensions(3);
    
    denmark_names(ind_img).FOV_x = denmark_names(ind_img).ImageSize_x*denmark_names(ind_img).PixelDimensions_x;
    denmark_names(ind_img).FOV_y = denmark_names(ind_img).ImageSize_y*denmark_names(ind_img).PixelDimensions_y;
    denmark_names(ind_img).FOV_z = denmark_names(ind_img).ImageSize_z*denmark_names(ind_img).PixelDimensions_z;
    
    denmark_names(ind_img).qoffset = [info.raw.qoffset_x ,info.raw.qoffset_y ,info.raw.qoffset_z ];
    denmark_names(ind_img).TransformMat= info.Transform.T;  
end

% Bordeaux
for ind_img = 1:length(bordeaux_names)
    image_folder_filepath = fullfile(bordeaux_names(ind_img).folder,bordeaux_names(ind_img).name,'\image');
    nii_file_path = fullfile(image_folder_filepath,'image.nii');
    if ~exist(nii_file_path, 'file')
        disp(['Decompressing: ', bordeaux_names(ind_img).name])
        gunzip(image_folder_filepath);
    end
    info = niftiinfo(nii_file_path);
    bordeaux_names(ind_img).ImageSize = info.ImageSize;
    bordeaux_names(ind_img).ImageSize_x = info.ImageSize(1);
    bordeaux_names(ind_img).ImageSize_y = info.ImageSize(2);
    bordeaux_names(ind_img).ImageSize_z = info.ImageSize(3);    
    
    bordeaux_names(ind_img).PixelDimensions_x = info.PixelDimensions(1);
    bordeaux_names(ind_img).PixelDimensions_y = info.PixelDimensions(2);
    bordeaux_names(ind_img).PixelDimensions_z = info.PixelDimensions(3);
    
    bordeaux_names(ind_img).FOV_x = bordeaux_names(ind_img).ImageSize_x*bordeaux_names(ind_img).PixelDimensions_x;
    bordeaux_names(ind_img).FOV_y = bordeaux_names(ind_img).ImageSize_y*bordeaux_names(ind_img).PixelDimensions_y;
    bordeaux_names(ind_img).FOV_z = bordeaux_names(ind_img).ImageSize_z*bordeaux_names(ind_img).PixelDimensions_z;
    
    bordeaux_names(ind_img).qoffset = [info.raw.qoffset_x ,info.raw.qoffset_y ,info.raw.qoffset_z ];
    bordeaux_names(ind_img).TransformMat= info.Transform.T;  
end

%% Explore Images
z_axis_variance =[denmark_names.ImageSize_z, bordeaux_names.ImageSize_z];
z_axis_rdim = [denmark_names.FOV_z, bordeaux_names.FOV_z];
Counts_img = struct();
Counts_img.value = z_axis_variance' ;
writetable(struct2table(Counts_img),'Figure_variation_resampled_forhist.csv','Delimiter',',')  
%%
unique_items = unique(z_axis_variance);
freq_count = histc(z_axis_variance,unique_items);
Counts_img = struct();
Counts_img.value = unique_items';
Counts_img.frequency = freq_count';
%writetable(struct2table(Counts_img),'Figure_variation_resampled.csv','Delimiter',',')  

%% Create 3 sets, training, val and test.
% Create directory for images and landmarks

data_preprocessed_dir = strcat(root_filespath,'\LAA_prep_data_resized');
training_data_dir = strcat(data_preprocessed_dir,'\LAA_training');
validation_data_dir = strcat(data_preprocessed_dir,'\LAA_validation');
testing_data_dir = strcat(data_preprocessed_dir,'\LAA_testing');

if ~exist(data_preprocessed_dir, 'dir')
    
    mkdir(data_preprocessed_dir)
    
    mkdir(training_data_dir)
    mkdir(fullfile(training_data_dir,'images'))
    mkdir(fullfile(training_data_dir,'landmarks'))    
    mkdir(fullfile(training_data_dir,'filenames'))
    
    mkdir(validation_data_dir)
    mkdir(fullfile(validation_data_dir,'images'))
    mkdir(fullfile(validation_data_dir,'landmarks'))
    mkdir(fullfile(validation_data_dir,'filenames'))
    
    mkdir(testing_data_dir)
    mkdir(fullfile(testing_data_dir,'images'))
    mkdir(fullfile(testing_data_dir,'landmarks'))
    mkdir(fullfile(testing_data_dir,'filenames'))
end

%% copy, rename, and randomize 
% !randomize_data was changed and not tested but it should work
% Bordeaux
randomize_data(root_filespath,data_preprocessed_dir,bordeaux_names,0.7,0.2);
% randomize_data(root_filespath,data_preprocessed_dir,bordeaux_names,0.7,0.2,[256,256,305]);
% Denmark
randomize_data(root_filespath,data_preprocessed_dir,denmark_names,0.7,0.2);
% randomize_data(root_filespath,data_preprocessed_dir,denmark_names,0.7,0.2,[256,256,305]);
%% Create Create reading files
write_txt(data_preprocessed_dir,'training');
write_txt(data_preprocessed_dir,'testing');
write_txt(data_preprocessed_dir,'validation');