function [x,y] = sortPolygonVertices(x,y)

xc = mean(x);
yc = mean(y);

angle = zeros(1,numel(x));

for i=1:numel(x)
    angle(i) = atan2((y(i)-yc),(x(i)-xc));
end

[angle,ind] = sort(angle);

x = x(ind);
y = y(ind);

end