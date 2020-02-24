function [A,hin,hout] = getAreaLocalMC(input,xmin,xmax,ymin,ymax,MCpoints,debug)

A = 0;

xmin = xmin - (xmax-xmin)/2;
ymin = ymin - (ymax-ymin)/2;
xmax = xmax + (xmax-xmin)/2;
ymax = ymax + (ymax-ymin)/2;

xin = xmin + (xmax-xmin) * rand(MCpoints,1);
yin = ymin + (ymax-ymin) * rand(MCpoints,1);

in = ones(1,MCpoints);

for point=1:MCpoints
    for disk=1:size(input,1)
        dxx=(input(disk,3)) - xin(point);
        dyy=(input(disk,4)) - yin(point);
        ddnm2=(dxx.^2+dyy.^2);
        if ddnm2 > (input(disk,5)*input(disk,5))/4
            in(point) = 0;
            continue
        end
    end
end

ratio = sum(in)/MCpoints;

in = logical(in);

if debug
    hin = scatter(xin(in),yin(in),'y.');
    hout = scatter(xin(~in),yin(~in),'c.');
end

A = ratio * (xmax-xmin) * (ymax-ymin);

end