classdef ExampleObject
    properties(Access=public)
        config
    end
    methods
    function self=ExampleObject(config)
        self.config = config;
        self.printConf();
    end
    function printConf(self)
        % Print configuration
        fprintf(OmegaConf.to_yaml(self.config));
    end
    end
end