function [res] = eval_calibration(A, b, extr)
    res = A*extr - b;
end

