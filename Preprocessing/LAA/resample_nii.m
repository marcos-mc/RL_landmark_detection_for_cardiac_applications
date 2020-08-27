function [outputArg1,outputArg2] = resample_nii(nii_filepath,where_to,new_size)
%RESAMPLE_NII Summary of this function goes here
%   Detailed explanation goes here
info = niftiinfo(nii_filepath);
V = niftiread(info);
B = imresize3(V,new_size);
new_info=info;
%imagesize/newsize * diag
% RZS = affine[:3, :3]
%     zooms = np.sqrt(np.sum(RZS ** 2, axis=0))
%     scale = np.divide(target_zooms, zooms)
%     ret[:3, :3] = RZS * np.diag(scale)
%     return ret

niftiwrite(B,where_to,new_info,'Compressed',true);
outputArg1 = nii_filepath;
outputArg2 = where_to;

info = niftiinfo(nii_filepath);
V = niftiread(info);
B = imresize3(V,new_size);
new_info=info;

new_info.ImageSize = new_size;
cnv_rate = (info.ImageSize ./new_size);
new_info.PixelDimensions = info.PixelDimensions.*cnv_rate
info.Transform.T(1:3,1:3) = info.Transform.T(1:3,1:3).*diag(cnv_rate);
new_info.raw.dim(2:4) = new_info.ImageSize;
new_info.raw.pixdim(2:4) = new_info.PixelDimensions;

niftiwrite(B,where_to,info,'Compressed',true);

end

