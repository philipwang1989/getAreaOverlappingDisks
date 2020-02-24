function [A, A_mc] = calcArea(x,y,th,r_shape,th_shape,Dn,R2n,Lx,Ly,gam,nn,mm,nnn_list,mmm_list,debug)
%%
% debug = 1;
A = 0;
A_mc = 0;
n_overlap = numel(nnn_list) + numel(mmm_list);
if n_overlap == 2
    nnn = nnn_list;
    mmm = mmm_list;
    DDnm=(Dn(nn)+Dn(mm))/2;
    rymmm=r_shape(mm,mmm)*sin(th(mm)+th_shape(mm,mmm));
    rynnn=r_shape(nn,nnn)*sin(th(nn)+th_shape(nn,nnn));
    dyy=(y(mm)+rymmm)-(y(nn)+rynnn);
    im=round(dyy/Ly);
    dyy=dyy-im*Ly;  % Periodic x
    rxmmm=r_shape(mm,mmm)*cos(th(mm)+th_shape(mm,mmm));
    rxnnn=r_shape(nn,nnn)*cos(th(nn)+th_shape(nn,nnn));
    dxx=(x(mm)+rxmmm)-(x(nn)+rxnnn);
    dxx=dxx-round(dxx/Lx-im*gam)*Lx-im*gam*Lx;
    ddnm2 = dxx.^2+dyy.^2;
    ddnm=sqrt(ddnm2);
    if(ddnm<DDnm)
        Q1 = 2*R2n(mm)*acos(ddnm/Dn(mm));
        Q2 = -0.5*ddnm*sqrt(Dn(mm)*Dn(mm)-ddnm2);
        A = Q1 + Q2;
        A_mc = A;
    end
elseif n_overlap > 2
    % step 1, make an array of relevant data
    input = zeros(n_overlap, 5); % nn, nnn, x, y, Dn
    count = 0;
    for i=1:numel(nnn_list)
        nnn = nnn_list(i);
        count = count + 1;
        input(count,1) = nn;
        input(count,2) = nnn;
        rxnnn=r_shape(nn,nnn)*cos(th(nn)+th_shape(nn,nnn));
        xb = x(nn)+rxnnn;
        input(count,3) = xb;
        rynnn=r_shape(nn,nnn)*sin(th(nn)+th_shape(nn,nnn));
        yb = y(nn)+rynnn;
        input(count,4) = yb;
        input(count,5) = Dn(nn);
    end
    for i=1:numel(mmm_list)
        mmm = mmm_list(i);
        count = count + 1;
        input(count,1) = mm;
        input(count,2) = mmm;
        rxmmm=r_shape(mm,mmm)*cos(th(mm)+th_shape(mm,mmm));
        xb = x(mm)+rxmmm;
        input(count,3) = xb;
        rymmm=r_shape(mm,mmm)*sin(th(mm)+th_shape(mm,mmm));
        yb = y(mm)+rymmm;
        input(count,4) = yb;
        input(count,5) = Dn(mm);
    end
    
    % step 2, return useful nodes and pairs as a table
    [table, isValid] = isValidSegment(input,Lx,Ly,gam);
    if ~isValid
        if debug
            h = [];
            for i=1:size(input,1)
                h(i) = viscircles([input(i,3),input(i,4)],input(i,5)/2,'Color','k');
            end
        end
        if debug
            delete(h);
        end
%         disp("Not a valid segment!");
        A = 0;
        return
    end
    if debug
        figure(1)
        h = [];
        hnodes = [];
        xmin = inf;
        xmax = -inf;
        ymin = inf;
        ymax = -inf;
        count_nodes = 0;
        for i=1:numel(table)
            h(i) = viscircles([table(i).x,table(i).y],table(i).R,'Color','k');
            if ~isempty(table(i).nodes)
                for j=1:numel(table(i).nodes)
                    count_nodes = count_nodes + 1;
                    nodes = table(i).nodes{j};
                    xnode = nodes(1);
                    ynode = nodes(2);
                    xmin = min([xmin,xnode]);
                    ymin = min([ymin,ynode]);
                    xmax = max([xmax,xnode]);
                    ymax = max([ymax,ynode]);
                    hnodes(count_nodes) = viscircles([xnode,ynode],table(i).R/100,'Color','y');
                end
            end
        end
        MCpoints = 5e6;
        [A_mc, hin, hout] = getAreaLocalMC(input,xmin,xmax,ymin,ymax,MCpoints,debug);
    end
    % step 3, get circular area
    valid_vert = 0;
    for i=1:numel(table)
        if ~isempty(table(i).nodes)
            table(i).circularA = getCircularSegmentArea(table(i).Dn,table(i).a);
            A = A + table(i).circularA;
            valid_vert = valid_vert + 1;
        end
    end
    
    % step 4, get n-polygon area
    coordinates = zeros(valid_vert*2,2);
    count_vert = 0;
    for i=1:numel(table)
        if ~isempty(table(i).nodes)
            count_vert = count_vert + 1;
            coordinates(2*(count_vert-1)+1,1) = table(i).nodes{1,1}(1);
            coordinates(2*(count_vert-1)+1,2) = table(i).nodes{1,1}(2);
            coordinates(2*(count_vert-1)+2,1) = table(i).nodes{1,2}(1);
            coordinates(2*(count_vert-1)+2,2) = table(i).nodes{1,2}(2);
        end
    end
    A = A + getPolygonArea(coordinates);
    if debug
        htitle = title((A-A_mc)/A);
    end
    if debug
        if abs(A-A_mc)/A > 1e-2
            pause();
        end
        delete(htitle);
        delete(h);
        delete(hnodes);
        delete(hin);
        delete(hout);
    end
end



%%
% hold on
% for i=1:3
%     scatter(table(i).nodes{1,1}(1),table(i).nodes{1,1}(2),'kx');
%     scatter(table(i).nodes{1,2}(1),table(i).nodes{1,2}(2),'kx');
% end
% axis xy equal

end