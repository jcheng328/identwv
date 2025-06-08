init_enviroment;

% Specify the data configuration path here and how many times you'd like to
% repeat the identification on the given dataset. 
dataConfig = "./Data/KdV/KdV.yaml";
numRepeat = 1;

% Initialize the service
serviceConfig = "./Service/Ident_Service.yaml";
config = OmegaConf.load(...
    serviceConfig, ...
    sprintf('dataset.x__inherit__=%s', dataConfig), ...
    sprintf('dataset.repeat=%d', numRepeat) ...
);
OmegaConf.to_yaml(config)
service_handler = createObject(config);

% Loop for identification, check the log @
% .\Results\ModelHandler\identwv\{your_dataset_name}\Output_identwv_{your_dataset_name}.txt
service_handler.loopIdentify();