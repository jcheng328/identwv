function obj = createObject(config)
clsname = config.("x__object__").get("path", []);
as_args = config.("x__object__").get("args", "as_config");
if isempty(clsname)
    error("Missing object path.")
end
[folder_path, class_name] = split_path(clsname);
addpath(folder_path);
cls = str2func(class_name); 
if strcmp(as_args, "as_config")
    obj = cls(config);
elseif strcmp(as_args, "as_params")
    params = config.unpack(); 
    magic_idx = find(startsWith(params(1:2:end), 'magic'));
    params(union(magic_idx*2-1, magic_idx*2)) = [];
    obj = cls(params{:});
end
end
function [folder_path, class_name]=split_path(module_path)
% Split at the last dot to separate folder and class
split_path = strsplit(module_path, '.');
folder_path = strjoin(split_path(1:end-1), '/');  % Join everything before the class name
class_name = split_path{end};  % The class name is the last element
end