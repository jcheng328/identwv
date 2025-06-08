classdef Metadata < handle
    % Formatting metadata class
    properties (Access=public)
        % struct of logical
        % Flags have 3 modes:
        %   unset : inherit from parent ([] if no parent specifies)
        %   set to true: flag is true
        %   set to false: flag is false
        flags {isstruct} = struct()

        % if true, when checking the value of a flag, if the flag is not 
        % set, [] is returned, otherwise, the parent node is queried.
        flags_root {isscalar, islogical} = false
    end
    methods
        function obj = Metadata(NameValueArgs)
            arguments
                NameValueArgs.flags {isstruct} = struct()
                NameValueArgs.flags_root {isscalar, islogical} = false
            end
            obj.flags = NameValueArgs.flags;
            obj.flags_root = NameValueArgs.flags_root;
        end
    end
end