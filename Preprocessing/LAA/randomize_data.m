function [done_bool] = randomize_data(root_filespath, where_to_dir,data_info,train_per,val_per,size_to_resize)
% Moves images --> changes name and recalculates landmarks (voxel coords)
% 1.copy .gz with different name from the folder in temp_images 
% 2.read lm , store as [vect;1], mult by [-1;-1;1;1], then transform with
% 3.inv(transformMat')*([vect;1].*[-1;-1;1;1]). Finally store res(1:end-1)
% 4.repeat for 3 landmarks, save in 1 txt with same name as folder in
% 5.store in temp_landmarks folder.


try
    switch nargin
        case 5
            use_resample = false;            
        case 6
            fprintf("Resampling is disabled as MATLAB's Niftiwrite has an error:\n");
            disp('<a href = "https://www.mathworks.com/matlabcentral/answers/511854-niftiread-niftiwrite-cycle-inappropriately-changes-image-orientation">The MathWorks Web Site adressing the issue</a>')
            done_bool = 0;
            return
            use_resample = true;
    end
    
    temp_data_dir = fullfile(root_filespath,'\LAA_temp');
    temp_data_dir_img = fullfile(root_filespath,'\LAA_temp\images');
    temp_data_dir_lm = fullfile(root_filespath,'\LAA_temp\landmarks');

    if ~exist(temp_data_dir, 'dir')
        mkdir(temp_data_dir)
        mkdir(temp_data_dir_lm)
        mkdir(temp_data_dir_img)
    end

    num_files = length(data_info);
    %fprintf('From\nImages: %s\nLandmarks: %s\n',where_to_img,where_to_lm)
    for ind_img=1:num_files
        current_name = data_info(ind_img).name;
        % Create Images (change names)
        
        source_image_filepath_from = fullfile(data_info(ind_img).folder,...
            data_info(ind_img).name,'\image\image.nii');        
        image_filepath_from = fullfile(data_info(ind_img).folder,...
            data_info(ind_img).name,'\image\image.nii.gz');
        old_name = 'image.nii.gz';
        new_name = strcat(data_info(ind_img).name,'.nii.gz');
        image_filepath_to = fullfile(temp_data_dir_img,new_name);    
        data_info(ind_img).path_img = image_filepath_to;
        data_info(ind_img).img_name = new_name;
        
        if exist(image_filepath_from, 'file')
            if ~exist(image_filepath_to, 'file')
                fprintf('Copying image %s:\n',data_info(ind_img).name)
                fprintf('\tFROM %s\tTO\t %s\n',image_filepath_from,image_filepath_to)
                
                if use_resample
                    %resample_nii(image_filepath_from,fullfile(temp_data_dir_img,new_name),size_to_resize)
                else
                    copyfile(image_filepath_from, temp_data_dir_img);
                    fprintf('Changed name FROM %s\tTO\t %s\n',old_name,new_name)
                    movefile(fullfile(temp_data_dir_img,old_name),fullfile(temp_data_dir_img,new_name));
                end
            end
        else
            if exist(source_image_filepath_from, 'file')
                fprintf('Compressing %s\tTO\t %s\n',source_image_filepath_from,temp_data_dir_img)
                gzip(source_image_filepath_from,temp_data_dir_img)
                fprintf('Changed name FROM %s\tTO\t %s\n',old_name,new_name)
                movefile(fullfile(temp_data_dir_img,old_name),fullfile(temp_data_dir_img,new_name));
            else
                fprintf('Source image not found for %s',data_info(ind_img).name)
            end
            
        end
        % Create Landmarks
        new_name_lm = strcat(data_info(ind_img).name,'.txt');
        path_to_lm_file = fullfile(temp_data_dir_lm,new_name_lm);        
        data_info(ind_img).path_lm = path_to_lm_file;
        data_info(ind_img).lm_name = new_name_lm;
        
        if ~exist(path_to_lm_file, 'file')
            
            landmark_names = {'circumflex.txt','landingZone.txt','ostium.txt'};
            print_to_file= zeros(length(landmark_names),3);
            for ind_lm =1:length(landmark_names)
                landmark_filepath_from = fullfile(data_info(ind_img).folder,...
                data_info(ind_img).name,'annotations',landmark_names(ind_lm));
                landmark_filepath_from = string(landmark_filepath_from); 
                %open txt files
                fileID = fopen(landmark_filepath_from,'r');         
                %apply affine mat
                phy_coord_lm = [fscanf(fileID,'%f;%f;%f');1]; 
                vox_coord_lm = data_info(ind_img).TransformMat'\(phy_coord_lm.*[-1;-1;1;1]);
                vox_coord_lm = round(vox_coord_lm);
                vox_coord_lm = vox_coord_lm(1:3)+1; %compensate 0 offset
                print_to_file(ind_lm,:) = vox_coord_lm;  
                fclose(fileID);
            end
            
            %Write the txt file
            fid = fopen(path_to_lm_file,'wt');        
            for ii = 1:size(print_to_file,1)
                fprintf(fid,'%g,%g,%g\n',...
                    print_to_file(ii, 1),...
                    print_to_file(ii, 2),...
                    print_to_file(ii, 3)); %Format of txt
            end
            fclose(fid);
        end
    end
    
    %% Randomization
    
    idx=randperm(num_files);    
    val_per = train_per+val_per;
    start_index_val = round(train_per*num_files);
    start_index_test = round(val_per*num_files);    
      
    train_indexes = idx(1:start_index_val);
    val_indexes =  idx(1+start_index_val:start_index_test);
    test_indexes = idx(1+start_index_test:end) ;

    %Training
    for ind=1:length(train_indexes)
        
        train_img_name = fullfile(where_to_dir,'LAA_training','images',...
            data_info(train_indexes(ind)).img_name);
        train_lm_name = fullfile(where_to_dir,'LAA_training','landmarks',...
            data_info(train_indexes(ind)).lm_name);
        
        if ~exist(train_img_name, 'file')
        movefile(data_info(train_indexes(ind)).path_img,train_img_name);
        end
        
        if ~exist(train_lm_name, 'file')
        movefile(data_info(train_indexes(ind)).path_lm,train_lm_name);
        end
    end
    
    %Validation
    for ind=1:length(val_indexes)
        
        val_img_name = fullfile(where_to_dir,'LAA_validation','images',...
            data_info(val_indexes(ind)).img_name);
        val_lm_name = fullfile(where_to_dir,'LAA_validation','landmarks',...
            data_info(val_indexes(ind)).lm_name);
        
        if ~exist(val_img_name, 'file')
        movefile(data_info(val_indexes(ind)).path_img,val_img_name);
        end
        
        if ~exist(val_lm_name, 'file')
        movefile(data_info(val_indexes(ind)).path_lm,val_lm_name);
        end
    end
    
    %Testing 
    for ind=1:length(test_indexes)
        
        test_img_name = fullfile(where_to_dir,'LAA_testing','images',...
            data_info(test_indexes(ind)).img_name);
        test_lm_name = fullfile(where_to_dir,'LAA_testing','landmarks',...
            data_info(test_indexes(ind)).lm_name);
        
        if ~exist(test_img_name, 'file')
        movefile(data_info(test_indexes(ind)).path_img,test_img_name);
        end
        
        if ~exist(test_lm_name, 'file')
        movefile(data_info(test_indexes(ind)).path_lm,test_lm_name);
        end
    end
    done_bool = 1;

catch 
    
    warning(['Error in: ',current_name]);
    done_bool = 0;
end
end

