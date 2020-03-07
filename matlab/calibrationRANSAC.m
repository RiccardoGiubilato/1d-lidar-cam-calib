function [bestModel, residuals, Abest, bbest, inliers] = calibrationRANSAC(planes, scans)

    fprintf('\nStarting RANSAC..\n');

    bestErr = Inf;  
    bestModel = [];
    inliers = NaN;
    
    numTot  = size(planes, 3);
    
    % RANSAC parameters
    numIter = 10000;
    numCand = 7;
    minConsensus = floor(0.8 * numTot);
    maxError     = 20;
    
    fprintf('Parameters: \nnumIter: %d  numCand: %d  minConsensus: %d,  maxErr: %1.2f \n', ...
        numIter, numCand, minConsensus, maxError);
    
    % Precompute matrices (A, b for all scans)
    [~, A0, b0] = LSpointplane(planes, scans);
    
    for iter = 1:numIter
        idx      = randperm(numTot, numCand);
        A = A0(idx, :);
        b = b0(idx, :);
        
        % Fit model using this scan subset and evaluate
        extr = (A' * A)^(-1) * A' * b;
        res = eval_calibration(A0, b0, extr);
        
        if length(res) ~= numTot
            error('Wrong ransac') 
        end
        
        % Find consensus
        if length(find(abs(res) < maxError)) > minConsensus
            inlierIdx = find(abs(res) < maxError);
            
            % Recompute model on inlier set
            A = A0(inlierIdx, :);
            b = b0(inlierIdx, :);
            extr = (A' * A)^(-1) * A' * b;
            err = norm(eval_calibration(A, b, extr));
                        
            % Compute new 
            res_all = abs(eval_calibration(A0, b0, extr));
            inlierIdx = find( res_all < maxError);
            A = A0(inlierIdx, :);
            b = b0(inlierIdx, :);
            
            if err < bestErr && length(find(abs(res_all) < maxError)) > minConsensus
                bestModel = extr;
                bestErr = norm(res);
                inliers = inlierIdx;
                residuals = res;
                Abest = A;
                bbest = b;
            end
        end
    end
    
%     bestConsensus = 0;
%     bestModel = [];
%     
%     % RANSAC parameters
%     numIter = 10000;
%     numCand = 10;
%     minConsensus = 20;
%     maxError     = 15;
%     
%     numTot  = size(planes, 3);
%     
%     % Compute initial model (A, b for all scans)
%     [~, A0, b0] = LSpointplane(planes, scans);
%     
%     for iter = 1:numIter
%         idx      = randperm(numTot, numCand);
%         A = A0(idx, :);
%         b = b0(idx, :);
%         
%         % Fit model using this scan subset and evaluate
%         extr = (A' * A)^(-1) * A' * b;
%         res = eval_calibration(A0, b0, extr);
%         
%         if length(res) ~= numTot
%             error('Wrong ransac') 
%         end
%         
%         % Find consensus
%         if length(find(abs(res) < maxError)) > minConsensus
%             inlierIdx = find(abs(res) < maxError);
%             
%             % Recompute model on inlier set
%             A = A0(inlierIdx, :);
%             b = b0(inlierIdx, :);
%             extr = (A' * A)^(-1) * A' * b;
%                         
%             % Compute new 
%             res_all = abs(eval_calibration(A0, b0, extr));
%             inlierIdx = find( res_all < maxError);
%             consensus = length(inlierIdx);
%             
%             if consensus > bestConsensus && length(find(abs(res_all) < maxError)) > minConsensus
%                 bestModel = extr;
%                 bestConsensus = consensus;
%                 inliers = inlierIdx;
%                 residuals = res;
%                 Abest = A;
%                 bbest = b;
%             end
%         end
%     end
%     
    fprintf('RANSAC terminated. \n %s     %s\n %d/%d %16.2f \n', 'n° inliers', 'resnorm', length(inliers), numTot, norm(res_all));
    fprintf('-----------------\nbestModel:\n');
    fprintf('%1.2f ', bestModel);
    fprintf('\n-----------------\n');
end