%% 

% Created by Philip Wang
% 000 PW Created on Feb. 23, 2020 at Yale University

% This program solves the overlapping area of two bumpy disks.
% See the following for bumpy disks:
% Papanikolaou, S., O?Hern, C. S., & Shattuck, M. D. (2013). 
% Isostaticity at frictional jamming. Physical review letters, 110(19), 198002.
% The journal paper can also be obtained from:
% https://jamming.research.yale.edu/files/papers/bump.pdf

% The program will be used as part of the method in a paper to be
% submitted in 2020 on frictional study of jammed particls.

% input: position of the particles and the bumps
% return: Alist = [label_p1, label_p2, A_analytical, A_mc];

%%
demo = 1;
if demo
    clear 
    close all
    clc
    load('data.mat');
    x(2) = x(2) - 0.001;
    n_s = n;
    n_l = n;
    Ns = n*Nc;

    plotit = 1;

    % Setup Plotting
    if plotit
        colorlist = ['r','b'];
        cr = 0;
        if ~ishandle(1)
            close all
        end
        fig1 = figure('Position',[100 100 1200 600]);
        clf;
        % small
        x_vert=flat((repmat(x(1:Nc)',[1,n_s])+r_shape.*cos(repmat(th(1:Nc)',[1,n_s])+th_shape))');
        y_vert=flat((repmat(y(1:Nc)',[1,n_s])+r_shape.*sin(repmat(th(1:Nc)',[1,n_s])+th_shape))');
        D_vert=flat((repmat(Dn(1:Nc)',[1,n_s]))');

        hs=zeros(Ns,3,3);
        he=[];
    %     cc=jet(N);    
        for np=1:Ns
            n1=ceil(np/n_s);
            for nn=-1:1
                for mm=-1:1;
                    hs(np,nn+2,mm+2)=rectangle('Position',[x_vert(np)-.5*D_vert(np)+nn*Lx+0*mm*Ly y_vert(np)-.5*D_vert(np)+mm*Ly D_vert(np) D_vert(np)],'Curvature',[1 1],'edgecolor',colorlist(n1),'facecolor','none');
                end
            end
        end

        for np=1:Nc
            n1=ceil(np/n_s);
            for nn=-1:1
                for mm=-1:1;
    %                 if np <= Nc/2
    %                 he(np,nn+2,mm+2)=viscircles([x(np),y(np)],r_shape(np,1),'Color',colorlist(np),'LineStyle','-','EnhanceVisibility',false);
                    he(np,nn+2,mm+2)=patch(x_vert((1:n)+(np-1)*n), y_vert((1:n)+(np-1)*n),colorlist(np),'EdgeColor','none');
    %                 end
                end
            end
        end
        hold on
        axis('equal'); box on; % set(gca,'XTick',[],'YTick',[])
        hb=plot([0 Lx Lx+0 +0 0],[0 0 Ly Ly 0],'k');

        axis('equal');
        axis([-Lx/4 5/4*Lx -Ly/4 5/4*Ly]);

        xlim([x(1), x(1)+2*R_eff(2)]);
        ylim([y(1)-R_eff(2), y(1)+R_eff(2)]);
    end
    
    debug = 1; % run analytics and MC comparison with 5e6 MC points for each subsegment
    [Alist] = getAreaOverlappingDisks(Nc,n,x,y,th,r_shape,th_shape,R_eff,Dn,Lx,Ly,gam,debug);
    disp(["Difference between analytical and MC is " + num2str(Alist(3)-Alist(4),'%e')]);
end

