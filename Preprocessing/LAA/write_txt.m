function [done_bool] = write_txt(where_dir,title)
%writes the txt files with the filepaths

folder_name = strcat('LAA_',title);

filelist_img = dir(fullfile(where_dir,folder_name,'\images'));  
filelist_img = filelist_img(~[filelist_img.isdir]);

filelist_lm = dir(fullfile(where_dir,folder_name,'\landmarks'));  
filelist_lm = filelist_lm(~[filelist_lm.isdir]);

rel_path = '.\\LAA_prep_data_resized';
fprintf('Using %s as relative Path\n',rel_path)

txt_name_img = strcat('LAA_img_files_',title,'.txt');
where_to = fullfile(where_dir,folder_name,'filenames',txt_name_img);


fid = fopen(where_to,'wt');
for ind = 1:length(filelist_img)    
    line_to_print = fullfile(rel_path,folder_name,'images',filelist_img(ind).name);
    line_to_print = replace(line_to_print,'\','/');
    fprintf(fid,'%s\n',line_to_print); %Format of txt
end
fclose(fid);

txt_name_lm = strcat('LAA_lm_files_',title,'.txt');
where_to = fullfile(where_dir,folder_name,'filenames',txt_name_lm);

fid = fopen(where_to,'wt');
for ind = 1:length(filelist_lm)    
    line_to_print = fullfile(rel_path,folder_name,'landmarks',filelist_lm(ind).name);
    line_to_print = replace(line_to_print,'\','/');
    fprintf(fid,'%s\n',line_to_print); %Format of txt
end
fclose(fid);

done_bool = 1;
end

