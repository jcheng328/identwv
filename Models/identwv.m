function [varargout] = identwv(data_config, sigmaSNR, rng_seed)
    arguments
        data_config
        sigmaSNR = 0
        rng_seed = []
    end
    addpath(genpath("./Lib/WeakIdent"))
    addpath(genpath("./Models/custom_functions"))
    if isempty(rng_seed)
        rng("shuffle")
        rng_seed = rng().Seed;
    else
        rng(rng_seed);
    end
    load(data_config.path, "U", "trueCoefficients", "xs");
    
    Uhat = addNoiseV2(U,sigmaSNR,rng_seed);
    
    if isempty(data_config.get("conv", []))
        xh = floor(length(xs{1})/100);
        th = floor(length(xs{end})/100);
    else
        xh = data_config.conv.get("stride_x", floor(length(xs{1})/100)); 
        th = data_config.conv.get("stride_t", floor(length(xs{end})/100));
    end
    useCrossDerivative = data_config.pde_lib.use_cross_derivative;
    max_dx = data_config.pde_lib.max_dx;
    polys = data_config.pde_lib.polys;
    Tau = data_config.get("Tau", 0.05);
    useErrDyn = data_config.get("useErrDyn", 0);
    IC = data_config.get("IC", []);
    
    indOfInterestingFeatures_arr = get_index_of_voting_features(Uhat, useCrossDerivative);
    [~, ~, tableOfEqn, tableErr, ~] = weakIdentV18_VotingV5(Uhat, xs, xh, max_dx, polys, Tau, trueCoefficients, useCrossDerivative, th, IC, useErrDyn, indOfInterestingFeatures_arr);


    % Create a struct with fields 'e2', 'einf', 'eres', 'tpr', and 'ppv' and
    % return
    ret = struct();
    ret.e2 = tableErr{tableErr{:,1}=="$E_2$", 2};
    ret.einf = tableErr{tableErr{:,1}=="$E_{\infty}$", 2};
    ret.eres = tableErr{tableErr{:,1}=="$E_{res}$", 2};
    ret.tpr = tableErr{tableErr{:,1}=="$TPR$",2};
    ret.ppv = tableErr{tableErr{:,1}=="$PPV$",2};
    ret.trueEqn = tableOfEqn{tableOfEqn{:,1}=="True", 2};
    ret.retEqn = tableOfEqn{tableOfEqn{:,1}=="WeakIdent", 2};
    varargout{1} = ret;
    if nargout == 2
        itemizedResults = struct();
        itemizedResults.Uhat = [];
        itemizedResults.W = [];
        itemizedResults.b = [];
        itemizedResults.S = [];
        itemizedResults.tags = [];
        varargout{2} = itemizedResults;
    end
    rmpath(genpath("./Lib/WeakIdent"))
    rmpath(genpath("./Models/custom_functions"))
    end