
filepath= 'F:\Andrea 4Dflow\human_reproducibility_segmentation\testing_human_reproducibility_computed\';
output= 'F:\Andrea 4Dflow\human_reproducibility_segmentation\aorta_test_data';
n=dir(filepath);

v=zeros(160,160,160);
m=zeros(160,160,160);
i=3;

while(i<=length(n))
    
    cd([filepath,n(i).name,'\angio']);
    im=dir;
    filename=(im(3).name);
    idx=strfind(filename,'.dcm');
    id=filename(idx-3:idx-1);        
    B = str2num(cell2mat(regexp(id,'\d*','Match')));
    name=char([filename(1:(idx-4)),regexprep(id,'[\d"]','')]);
    
    try
        for j=(1+B):(159+B)
            f=[name,num2str(j),filename(idx:end)];
            v(:,:,j)=dicomread(f);
        end
    catch
        for j=(1+B):(159+B)
            f=[name,sprintf('%03d',j),filename(idx:end)];
            v(:,:,j)=dicomread(f);
        end
    end
            
    cd([filepath,n(i).name,'\mask_final_long']);
    ma=dir;
    filename=(ma(3).name);
    B=str2num(ma(3).name(end));
    try
        for j=(1+B):(159+B)
            f=['ANON_IM',num2str(j)];
            m(:,:,j)=dicomread(f);
        end
    catch
        for j=(1+B):(159+B)
           f=['ANON_IM',sprintf('%03d',j)];
           m(:,:,j)=dicomread(f);
        end
    end

    cd(output)
    niftiwrite(v,([n(i).name,'.nii']));
    niftiwrite(m,([n(i).name,'_m.nii']));
    
    
    i=i+1;
    disp(i)
end
    


