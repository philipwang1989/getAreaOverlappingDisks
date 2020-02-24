function [res] = getSubset(arr)
    res = {};
    function [] = helper(first,curr)
        if nargin == 0
            first = 1;
            curr = [];
        end
        if numel(curr) == k
            res = [res,curr];
        end
        for i=first:numel(arr)
            curr = [curr,arr(i)];
            helper(i+1, curr);
            curr = curr(1:end-1);
        end
    end
    n = numel(arr);
    for k=1:n+1
        helper();
    end
end
