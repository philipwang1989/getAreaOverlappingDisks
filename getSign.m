function [sign] = getSign(count)

if mod(count,2) == 0
    sign = -1;
else
    sign = 1;
end

end