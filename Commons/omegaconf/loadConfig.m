function config = loadConfig(path, varargin)
    config = OmegaConf.load(path);
    if nargin > 1
        config_argv = OmegaConf.from_dotlist(varargin{:});
        config = OmegaConf.merge(config, config_argv);
    end
    config = OmegaConf.resolve_children_inheritance(config);
end
