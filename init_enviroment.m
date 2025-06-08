
% Remove working directory

workdir_root = './';
warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath(workdir_root));
warning('on', 'MATLAB:rmpath:DirNotFound');

% Add the following folders to search path
folders = {
    "./Commons/omegaconf", ...
    "./Commons", ...
    "./Models", ...
    "./Service"
};
gen_folders = convertCharsToStrings(cellfun(@genpath, folders, 'UniformOutput', false));
addpath("./", gen_folders{:});