function k = kernal_RQ(h,sigma,alpha,l)
% Rational quadratic kernal function

k = sigma^2.*(1+h.^2./(2*alpha*l^2)).^(-alpha);

end