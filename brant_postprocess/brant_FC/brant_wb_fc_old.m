function [cor_R, cor_Z] = brant_wb_fc(TS_ROI,Mask,TS_Total)
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Read analyze format file.
% FORMAT
% function [cor_R, cor_Z] = brant_roi_fc(TS_ROI,Mask,TS_Total)
% Input  TS_ROI ---  the mean time series of the ROI
%            Mask --- the mask of the brain, if the voxel with the brain,
%                           the value is 1, otherwise is 0
%            TS_Total -- A 4-dim time series of the Brain.

% Output cor_R ---- correlation coefficients between ROI's time course and
%                               other voxels in the whole brain
%                 cor_Z ---- Z-value of correlation coefficients
%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu, Oct,2007
% LIAMA Center for Computational Medicine (CMC),
% www.brainspans.com/peoples/YongLiu.html
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007,
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also

warning off MATLAB:divideByZero
%-----------------------------------------------------------------------

% compute the mean time courses of ROI
% % TC_ROI=zeros(T,1);
% % for k=1:size(ROI,1)
% %     TC_ROI=TC_ROI+squeeze(TC_total(ROI(k,1),ROI(k,2),ROI(k,3),:));
% % end
% % TC_ROI=TC_ROI/size(ROI,1);

% compute the correlation coefficients between the ROI's time course and
% other voxels in the whole brain
volumesize = zeros(1,3);
[volumesize(1),volumesize(2),volumesize(3),T] = size(TS_Total);
cor_R=zeros(volumesize(1),volumesize(2),volumesize(3));
cor_Z=zeros(volumesize(1),volumesize(2),volumesize(3));
%% compute the correlation coefficients and Z value between the ROI and other
%% voxels within the Mask
for i=1:volumesize(1)
    for j=1:volumesize(2)
        for k=1:volumesize(3)
            if Mask(i,j,k)>0.5
                I = find(squeeze(TS_Total(i,j,k,:)));
                if length(I)==0
                    %%% do nothing
                else
                    timecourse=squeeze(TS_Total(i,j,k,:));
                    R=corrcoef(TS_ROI,timecourse);
                    r=R(1,2);
                    if r==1;
                        r=0.9999;
                    end
                    cor_R(i,j,k)=r;
                    cor_Z(i,j,k)=0.5*log((1+r)/(1-r));   % Fisher's Z transformationZ;
                end
            end
        end
    end
end