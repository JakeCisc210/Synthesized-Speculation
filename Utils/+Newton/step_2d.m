function [dx1, dx2,singularJacobian] = step_2d(function1,function2,x1,x2,h)
% Two Dimensional Root Finding via Newton's Method
% The purpose of this function is to compute dx1 and dx2 such that the
% inputs x1+dx1 and x2+dx1 comer close to setting function1 and function2
% to zero. h is the finite distance constant, which is
% used to approximate the partial derivatives of both functions using a
% fourth order finite difference method.

    % TODO: See if you can specify order of finite difference method and get the coefficients through MATLAB
    
    % Partial derivatives approximated using fourth order finite difference method
    coeffs = [1 -8 8 -1]/(12*h);
    x1Spread = x1*ones(1,4)+[-2*h -h h 2*h]; 
    x2Spread = x2*ones(1,4)+[-2*h -h h 2*h];
    dFunction1dX1 = dot(coeffs,function1(x1Spread,x2*ones(1,4)));
    dFunction1dX2 = dot(coeffs,function1(x1*ones(1,4),x2Spread));
    dFunction2dX1 = dot(coeffs,function2(x1Spread,x2*ones(1,4)));
    dFunction2dX2 = dot(coeffs,function2(x1*ones(1,4),x2Spread));

    Jacobian = [dFunction1dX1, dFunction1dX2,; dFunction2dX1, dFunction2dX2];
    functionEvals = [function1(x1,x2); function2(x1,x2)];

    if abs(det(Jacobian)) <= 100*eps
        warning("Singular Jacobian")
        singularJacobian = 1;
        dx1 = 0; dx2 = 0;
    else
        singularJacobian = 0;
        dxValues = -1*Jacobian\functionEvals;
        dx1 = dxValues(1);
        dx2 = dxValues(2);
    end
    
end