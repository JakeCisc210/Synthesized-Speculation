n = 1000;
T = 21;
dt = T/n;
mu = 1/10;
times = dt:dt:T;
sigma = 1/5;
S0 = 10;

numTrials = 3000;
log_endPoint = zeros(1,numTrials);
for ii = 1:numTrials
    Scurrent = S0;
    S = zeros(1,n+1);
    S(1) = Scurrent;
    for jj = 1:n
        Scurrent = S(jj) + mu*S(jj)*dt + sigma*S(jj)*sqrt(dt)*normrnd(0,1);
        S(jj+1) = Scurrent; 
    end 
    log_endPoint(ii) = log(S(end));
end
histogram(log_endPoint)
mean(log_endPoint)
var(log_endPoint)
expectedMean = (mu-sigma^2/2)*T+log(S0)
expectedVar = sigma^2*T
 % ??????
