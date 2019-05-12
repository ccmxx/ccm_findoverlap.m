%% this script finds overlapping activated voxels among one or more SPM contrasts(studies), and writes the overlapping map into nii file.
% it requires SPM12 and Marsbar
% get the clusters, details are in mars_blob_menu.m;
% defaults: currently it can support one or multiple contrasts
% developed by Changming Chen, 2018/09/30, @ Beijing Normal University


%% load the SPM.mat file from at least one study
%  meanwhile, define the threshold, default setting is to use the same threshold, but it also leaves the option to use different thresholds
%  see xSPM.thresDesc, xSPM.k
clear;
answer = inputdlg('How many contrasts would you like to find the overlapping ares?','please find the number of contrasts',1);
temp=str2double(answer{1});
allspms=cell(1);
func='';
for i=1:temp
    try
        msg=['Please choose the SPM.mat for the       ', num2str(i), '        contrast'];
        [SPM,xSPM] = spm_getSPM;  % the GUI chooses the SPM.mat files and display results, I think I have to reedit and save it as a new file, to suppress the result report
        allspms{i,1}=SPM;
        allspms{i,2}=xSPM;
        allspms{i,3}=SPM.xCon(xSPM.Ic).Vspm.fname;
        allspms{i,4}=SPM.xCon(xSPM.Ic).name;
        allspms{i,5}=xSPM.u;
        allspms{i,6}=xSPM.k;
        allspms{i,7}=xSPM.swd;
        func=[func,'(i',num2str(i),'>',num2str(allspms{i,5}),').*'];
        clear SPM;
        clear xSPM;
%         exrois=mars_blobs2rois_ccm(xSPM,SPM.swd);
    catch
    end
end
matlabbatch=cell(1);
for i=1:size(allspms,1)
    inputs{i,1}=[fullfile(allspms{i,7},allspms{i,3}),',1'];
end
[outname,outdir]=uiputfile(pwd,'Please select the output director and tell me the output file name');
matlabbatch{1}.spm.util.imcalc.input = inputs;
matlabbatch{1}.spm.util.imcalc.output =fullfile(outdir,outname);
matlabbatch{1}.spm.util.imcalc.outdir = {outdir};
matlabbatch{1}.spm.util.imcalc.expression = func(1:end-2);
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run',matlabbatch);
try
    cprintf([1 0 0],['the output file is stored in     ', outdir]);
catch
    display(['the output file is stored in     ', outdir])
end