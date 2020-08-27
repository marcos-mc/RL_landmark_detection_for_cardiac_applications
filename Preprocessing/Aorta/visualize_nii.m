
clear all
addpath(".\NIfTI_tools")% Nifti visualizing package
%% 
% images files
filepath_img = ".\data\images\";
gz_path = strcat(filepath_img,'*.gz');
nii_files = gunzip(gz_path); % nii path

% landmarks files
landm_files = cell(1,length(nii_files));
del_this = length(char("_Normalized_to_002_S_0295"));
filepath_landm = ".\data\landmarks\";

for i=1:length(nii_files)    
    [~,landm_files{i},~] = fileparts(nii_files{i});
    landm_files{i} = strcat(landm_files{i}(1:end-del_this),'.txt');
    landm_files{i} = strcat(filepath_landm, landm_files{i});
end
%%
image_ind = 1; 
current_path = landm_files{image_ind};
fileID = fopen(current_path);
data = textscan(fileID,'%u %u %u','Delimiter',',');
image= nii_files{image_ind};
nii = load_nii(image);
k = 1;
option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
view_nii(nii,option);
h = gcf;
kmax = size(data{1},1); 

while 1
    try
        was_a_key = waitforbuttonpress;
    catch exception % avoids error when the window is clossed
        break
    end
    
    if was_a_key && strcmp(get(h, 'CurrentKey'), 'rightarrow')
        k = min(k + 1,kmax); %Decreases the landmark
        option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
        view_nii(h,nii,option);
        
    elseif was_a_key && strcmp(get(h, 'CurrentKey'), 'leftarrow')
        k = max(1, k - 1); %Decreases the landmark
        option.setviewpoint = [data{1}(k) data{2}(k) data{3}(k)];
        view_nii(h,nii,option);
    end
end