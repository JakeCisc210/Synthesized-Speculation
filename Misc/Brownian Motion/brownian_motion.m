numTrials = 1000;
endPoints = zeros(1,numTrials);
for ii = 1:numTrials
    n = 1000;
    T = 2;
    dt = T/n;
    times = dt:dt:T;
    dB = sqrt(dt)*normrnd(0,1,1,n);
    b0 = 0;
    B = horzcat(b0,cumsum(dB));
    endPoints(ii) = B(end);
end
histogram(endPoints)
mean(endPoints)
var(endPoints)
