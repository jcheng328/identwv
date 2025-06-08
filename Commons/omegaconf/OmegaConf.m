classdef OmegaConf < handle
    methods(Static)
        function config = load(path, varargin, NameValueArgs)
            arguments (Input)
                path {mustBeText}
            end
            arguments (Input, Repeating)
                varargin
            end
            arguments (Input)
                NameValueArgs.is_terminal_node {isscalar, islogical} = true
                NameValueArgs.parent {mustBeAorEmpty(NameValueArgs.parent, 'StructConfig')} = []
            end
            arguments (Output)
                config {mustBeA(config, 'StructConfig')}
            end
            config = StructConfig(yamlread(path),parent=NameValueArgs.parent);
            if nargin > 1
                config_argv = OmegaConf.from_dotlist(varargin{:});
                config = OmegaConf.merge(config, config_argv);
            end
            config = OmegaConf.resolve_inheritance(config);
            if NameValueArgs.is_terminal_node
                config = OmegaConf.resolve_children_inheritance(config);
            end
        end
        function ret = resolve_inheritance(config)
            %{
                Recursively resolve inheritance if the config contains 
                __inherit__: path/to/parent.yaml.

                The function yields a new object instead modify the
                original configuration.
            %}
            inherit = config.pop("x__inherit__");
            if ~isempty(inherit)
                base_config = OmegaConf.load(inherit, is_terminal_node=false, parent=config);
                if ~isempty(base_config)
                    config = OmegaConf.merge(base_config, config);
                else
                    warning("Cannot solve inheritance "+inheirt);
                end
            end
            ret = config;
        end
        function ret = resolve_children_inheritance(config)
            for t = enumerate(config.keys())
                k = t.item;
                v = config.(k);
                if isa(v, "StructConfig")
                    config.(k) = OmegaConf.resolve_inheritance(v);
                    config.(k) = OmegaConf.resolve_children_inheritance(config.(k));
                end
            end
            ret = config;
        end
        function set_readonly(conf, value)
            arguments
                conf
                value (1,1) logical
            end
            conf.set_flag("readonly", value)
        end

        function ret = is_readonly(conf)
            arguments (Input)
                conf
            end
            arguments (Output)
                ret (1,1) logical
            end
            ret = conf.get_flag("readonly");
        end
        function conf = create(NameValueArgs)
            arguments
                NameValueArgs.config = struct()
                NameValueArgs.parent = []
                NameValueArgs.flags = []
            end
            conf = StructConfig(NameValueArgs.config, parent=NameValueArgs.parent, flags=NameValueArgs.flags);
        end
        function conf = from_dotlist(varargin)
            %{
                usage: 
                    conf = from_dotlist(varargin)
                    conf = from_dotlist("a.d=1 b.e.f=1 c=1")
                    conf = from_dotlist('a.d=1 b.e.f=1 c=1')
            %}
            conf = OmegaConf.create();
            conf.merge_with_dotlist(varargin{:});
        end
        function update(config, key, value)
            if isstruct(value)
                value = StructConfig(value);
            end
            sp = split(key, '.'); root = config;
            for t = enumerate(sp)
                i = t.num; k = t.item;
                if i == length(sp)
                    root.(sp{end}) = value;
                else
                    if (~config.iskey(k))
                        root.(k) = StructConfig;
                    end
                    root = root.(k);
                end
            end
        end
        function target = merge(varargin)
            %{
                Merge a list of previously created configs into a single
                one.

                The returned merged config object is a new instance. Input
                configs remain unchanged.
                
                Merged_StructConfig = OmegaConf.merge(StructConfig, ..., None, ...);
                sometimes, config loading failed and None returned
            %}
            assert(nargin > 0)
            target = copy(varargin{1});
            turned_readonly = target.get_flag("readonly");
            target.set_flag("readonly", false);
            target.merge_with(varargin{2:end});
            if ~isempty(turned_readonly) && turned_readonly
                target.set_flag("readonly", true);
            end
        end
        function ret = to_yaml(data)
            if isa(data, "StructConfig")
                data = data.to_struct();
            end
            ret = yamlwrite(data);
        end
    end
end
    