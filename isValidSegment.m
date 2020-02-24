function [table, isValid] = isValidSegment(input,Lx,Ly,gam)
%% Step 0, prepare a data structure that keeps all the lens combinations
table = [];
count = 0;
isValid = true;
% M = containers.Map('KeyType','char','ValueType','any');
% for i=1:numel(nnn_list)
%     for j=1:numel(mmm_list)
%         count = count + 1;
%         table(count).nn = nn;
%         table(count).mm = mm;
%         table(count).nnn = nnn_list(i);
%         table(count).mmm = mmm_list(j);
%         key = char({num2str(nn),num2str(mm),num2str(nnn_list(i)),num2str(mmm_list(j))});
%         M(key) = count;
%     end
% end

%% Step 1, unwrap input array: nn, nnn, x, y, Dn
lens_pairs = nchoosek(1:size(input,1),2);
check_list = [];
full_list = 1:size(input,1);
for i=1:size(lens_pairs,1)
    check_list = [check_list;full_list(~ismember(full_list,lens_pairs(i,:)))];
end

%% Step 2, find lens geometry for each lens pairs
for i=1:size(lens_pairs,1)
    p1 = lens_pairs(i,1);
    p2 = lens_pairs(i,2);
    x = [input(p1,3),input(p2,3)];
    y = [input(p1,4),input(p2,4)];
    Dn = [input(p1,5),input(p2,5)];
    [flag,a,ddnm,DDnm,c1,c2] = getLensGeometry(x,y,Dn,Lx,Ly,gam);
    ddnm_pair = ddnm;
    DDnm_pair = DDnm;
    a_pair = a;
    if ~flag
        continue
    else
        % loop through check_list to identify valid node for each lens pair
        c_temp = [true,true];
%         valid_node = nan;
        for j=1:size(check_list,2)
            p = check_list(i,j);
            x = input(p,3);
            y = input(p,4);
            Dn = input(p,5);
            DDnm = Dn/2;
            DDnm2 = DDnm * DDnm;
            % bug here, consider the case of which:
            % 1. one of the two nodes is valid - done
            % 2. both are invalid
            % 3. both are valid! - pending
            % check c1
            dyy = c1(2) - y;
            im = round(dyy/Ly);
            dyy = dyy - im*Ly;  % Periodic x
            dxx = c1(1) - x;
            dxx = dxx-round(dxx/Lx-im*gam)*Lx-im*gam*Lx;
            ddnm2 = dxx.^2+dyy.^2;
            if ddnm2 >= DDnm2
                c_temp(1) = false;
            end
            % check c2
            dyy = c2(2) - y;
            im = round(dyy/Ly);
            dyy = dyy - im*Ly;  % Periodic x
            dxx = c2(1) - x;
            dxx = dxx-round(dxx/Lx-im*gam)*Lx-im*gam*Lx;
            ddnm2 = dxx.^2+dyy.^2;
            if ddnm2 >= DDnm2
                c_temp(2) = false;
            end
        end
        if ~c_temp(1) && ~c_temp(2)
            continue
        end
        % if the algorithm reached here, this is a good segment and we can
        % proceed with area calculation
        for node=1:numel(c_temp)
            if c_temp(node)
                count = count + 1;
                table(count).p1 = [input(p1,1),input(p1,2)]; % nn, nnn
                table(count).p2 = [input(p2,1),input(p2,2)];
                table(count).ddnm = ddnm_pair;
                table(count).DDnm = DDnm_pair;
                table(count).a = a_pair;
                if node == 1
                    table(count).valid_node = c1;
                end
                if node == 2
                    table(count).valid_node = c2;
                end
            end
        end
    end
end

if isempty(table)
    isValid = false;
    return
end

%% Step 3, organize the table such that each disk has two nodes which gives a
temp = table;
table = [];
for i=1:size(input,1)
    table(i).p = [input(i,1), input(i,2)];
    table(i).x = input(i,3);
    table(i).y = input(i,4);
    table(i).Dn = input(i,5);
    table(i).R = input(i,5)/2;
end

for i=1:numel(table)
    p = table(i).p;
    nodes = {};
    count_nodes = 0;
    for j=1:numel(temp)
        if all(temp(j).p1 == p)
            count_nodes = count_nodes + 1;
            nodes{count_nodes} = temp(j).valid_node;
%             continue
        end
        if all(temp(j).p2 == p)
            count_nodes = count_nodes + 1;
            nodes{count_nodes} = temp(j).valid_node;
%             continue
        end        
    end
    if numel(nodes) > 2
        disp("BUG!!! More than two nodes per disk!?\n");
    end
    table(i).nodes = nodes;
    if isempty(nodes)
        table(i).a2 = 0;
        table(i).a = 0;
    else
        a2 = sum((nodes{1} - nodes{2}).^2);
        table(i).a2 = a2;
        table(i).a = sqrt(a2);
    end
end



end