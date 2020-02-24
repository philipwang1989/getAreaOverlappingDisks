function A = getPolygonArea(coordinates)
A = 0;

xin = coordinates(:,1);
yin = coordinates(:,2);

x = [xin(1)];
y = [yin(1)];

xin(1) = nan;
yin(1) = nan;

while numel(x) < numel(xin)/2
    for i=1:numel(xin) % find identical
        if xin(i) == x(end) && yin(i) == y(end)
            xin(i) = nan;
            yin(i) = nan;
            break
        end
    end
    for i=1:numel(xin)
        if ~isnan(xin(i))
            x = [x,xin(i)];
            xin(i) = nan;
            y = [y,yin(i)];
            yin(i) = nan;
            break
        end
            
    end
end

% INTERESTING BUG USING POLYAREA
% MUST ROTATE CLOCKWISE OR COUNTERCLOXKWISE

%% swap
% xtemp = [x(1),x(3),x(2),x(4)];
% ytemp = [y(1),y(3),y(2),y(4)];
% polyarea(xtemp,ytemp)
if numel(x) > 2
    [x,y] = sortPolygonVertices(x,y);
end

%%
A = polyarea(x,y);

end

%%
% figure(2)
% for i=1:numel(x)
%     text(x(i),y(i),num2str(i));
%     hold on
% end
% [x,y] = sortPolygonVertices(x,y);
% for i=1:numel(x)
%     text(x(i),y(i),num2str(i),'Color','r');
%     hold on
% end

