function planes = generate_planes(cameraParams)

    planes = zeros(4,4,cameraParams.NumPatterns);
    for boardIdx = 1:cameraParams.NumPatterns            
                R = cameraParams.RotationMatrices(:, :, boardIdx)';
                t = cameraParams.TranslationVectors(boardIdx, :)';
                T = eye(4);
                T(1:3, 1:3) = R;
                T(1:3, 4) = t;
                planes(:, :, boardIdx) = T;
    end
    
end