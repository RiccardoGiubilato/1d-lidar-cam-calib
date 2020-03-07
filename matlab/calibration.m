function [extr, res, extr0, res0, extrLS, resLS, inliers] = calibration(planes, scans)

    % Check dimensions
    if (size(planes, 3) ~= length(scans))
       error('different number of planes and range measures! Terminating.') 
    end

    % Least Squares Solution (full set)
    [extrLS, ALS, bLS] = LSpointplane(planes, scans);
    resLS = eval_calibration(ALS, bLS, extrLS);    
    
    % Ransac
    [extr0, res0, A, b, inliers] = calibrationRANSAC(planes, scans);
    
    % Levenberg-Marquardt Refinement
    options = optimoptions('lsqnonlin','Display','iter');
    [extr, resnorm, res, ~, ~, ~, J] = lsqnonlin(@(extr) eval_calibration_versor_plane(A, b, extr), extr0, [], [], options);
    ci = nlparci(extr,res,'jacobian',full(J), 'alpha', 0.32);
    ci2 = ci(:,2) - ci(:,1);
    
    fprintf('refinedModel: \n');
    fprintf('%1.3f ', extr);
    fprintf('\n');
    
    fprintf('covariance: \n');
    fprintf('%1.3f ', ci2);
    fprintf('\n');

end