function value = linear_spike(p,center,spread)
    value = (abs(p-center)<= spread) .* (spread-abs(p-center))/(spread^2);
end