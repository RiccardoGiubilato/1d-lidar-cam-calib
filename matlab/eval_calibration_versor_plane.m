function [res] = eval_calibration_versor_plane(A, b, extr)
    res = A*extr - b;
    
    % Get normals
    np = A(:, 1:3);
    na = repmat(extr(4:6)', size(np, 1), 1);
    
    % Compute row-wise dot product
    ndot = sum(np.*na, 2);
    
    % Divide by product of norms of vectors
    corr = ndot ./ (vecnorm(np') .* vecnorm(na'))'; 
    
    % Correct res by vector angle cosine
    res = res./corr;   
end

