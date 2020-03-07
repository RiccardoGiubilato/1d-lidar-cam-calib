function [extr, A, b] = LSpointplane(planes, scans)

    % Set up least squares problem
    N = size(planes, 3);

    A = zeros(N, 6);
    b = zeros(N, 1);

    for i=1:N
       nx = planes(1,3,i); 
       ny = planes(2,3,i); 
       nz = planes(3,3,i); 

       px = planes(1,4,i); 
       py = planes(2,4,i); 
       pz = planes(3,4,i); 

       rho = scans(i);

       A(i,1) = nx;
       A(i,2) = ny;
       A(i,3) = nz;
       A(i,4) = rho*nx;
       A(i,5) = rho*ny;
       A(i,6) = rho*nz;

       b(i) = px*nx + py*ny + pz*nz;
    end

    % Solve least squares problem and compute residuals
    extr = (A' * A)^(-1) * A' * b;

end

