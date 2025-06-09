init_enviroment;

% data, model, and acronym
data = 'KdV';
models = {'identwv'};
acronym = {'Ident-WV'};

% Initialize the service and visualize results, check the log @
% .\Results\ModelComparer\{your_dataset_name}\Output_ModelComparer.txt
serviceConfig = "./Service/Compare_Service_TPR.yaml";
config = OmegaConf.load(serviceConfig);
handler = createObject(config);
handler.compare(data, models, acronym);

serviceConfig = "./Service/Compare_Service_PPV.yaml";
config = OmegaConf.load(serviceConfig);
handler = createObject(config);
handler.compare(data, models, acronym);

serviceConfig = "./Service/Compare_Service_E2.yaml";
config = OmegaConf.load(serviceConfig);
handler = createObject(config);
handler.compare(data, models, acronym);
