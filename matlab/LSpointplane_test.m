function [extr] = LSpointplane_test(input)

    % Set up least squares problem
    N = size(input, 1);

    A = zeros(N, 6);
    b = zeros(N, 1);

    for i=1:N
       nx = input(i, 1); 
       ny = input(i, 2); 
       nz = input(i, 3); 

       px = input(i, 4); 
       py = input(i, 5); 
       pz = input(i, 6); 

       rho = input(i, 7); 

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

