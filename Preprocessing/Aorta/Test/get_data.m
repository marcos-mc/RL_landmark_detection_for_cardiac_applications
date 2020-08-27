
main_dir = dir('testing_human_reproducibility_computed');
main_dir = main_dir(3:end,:);
guess_dir = dir('manually_reproduced');
guess_dir= guess_dir(3:end,:);

fid_test = fopen('.\distances.txt','wt');
fprintf(fid_test,'name,distance1,distance2,distance3,distance4\n');


for i=1:length(main_dir)
    
    real_lm_path = fullfile(main_dir(i).folder,main_dir(i).name,'reference_points','reference_points_mimics.txt');
    F_real=[];
    fid = fopen(real_lm_path,'r');
    
    while ~feof(fid)
        st = fgetl(fid);
        if  contains(st,["X0","X1","X2","X3","X4"])
            stread = textscan(st,'%s %s %s %f %f %f');
            F_real = [F_real; stread{[4,5,6]}];
        end
    end
    fclose(fid);
    
    guess_lm_path = fullfile(guess_dir(i).folder,guess_dir(i).name,'reference_points','reference_points_mimics.txt');
    
    F_guess=[];
    fid = fopen(guess_lm_path,'r');
    
    while ~feof(fid)
        st = fgetl(fid);
        if  contains(st,["X0","X1","X2","X3","X4"])
            stread = textscan(st,'%s %s %s %f %f %f');
            F_guess = [F_guess; stread{[4,5,6]}];
        end
    end
    fclose(fid);
    
    D  = sqrt(sum((F_guess - F_real).^ 2,2));
    
    fprintf(fid_test,'%s,', main_dir(i).name );
    fprintf(fid_test,'%g,%g,%g,%g\n', D(1), D(2), D(3), D(4)); %Format of txt  
end
fclose(fid_test);