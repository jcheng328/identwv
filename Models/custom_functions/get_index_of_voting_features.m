function [indOfInterestingFeatures_arr]=get_index_of_voting_features(Uhat, ref_useCrossDerivative)
    numOfU = length(Uhat);
    dimXandT          = length(size(Uhat{1}));
    ref_polys = [0,1,2];
    ref_max_dx = 2;
    if ~exist("ref_useCrossDerivative", "var")
        ref_useCrossDerivative = 0;
    end
    [~, indOfInterestingFeatures_arr, ~, ~] = getTagsV2(numOfU, dimXandT, [], ref_max_dx, ref_polys, ref_useCrossDerivative, {[]});
    idx = any(indOfInterestingFeatures_arr(:,1:numOfU)==1,2);
    indOfInterestingFeatures_arr(idx, :) = [];
    dimX = dimXandT -1;
    dimT = 1;
    ref_lhsIdx = [eye(numOfU),zeros(numOfU,dimX),ones(numOfU,dimT)];
    indOfInterestingFeatures_arr = [indOfInterestingFeatures_arr; ref_lhsIdx];
end