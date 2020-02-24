function [Alist] = getAreaOverlappingDisks(Nc,n,x,y,th,r_shape,th_shape,R_eff,Dn,Lx,Ly,gam,debug)

bb_contact_list = zeros(n,2);
Alist = [];

R2n = (Dn./2).^2;

for nn=1:Nc
    for mm=(nn+1):Nc
        dy=y(mm)-y(nn);
        im=round(dy/Ly);
        dy=dy-im*Ly;  % Periodic x
        Dnm=R_eff(nn)+R_eff(mm);
        if(abs(dy)<Dnm)
            dx=x(mm)-x(nn);
            dx=dx-round(dx/Lx-im*gam)*Lx-im*gam*Lx;
            dnm=sqrt(dx.^2+dy.^2);
            if(dnm<Dnm)
                A = 0;
                A_mc = 0;
                num_bump_contacts = 0;
                for nnn=1:n
                    for mmm=1:n
                        rymmm=r_shape(mm,mmm)*sin(th(mm)+th_shape(mm,mmm));
                        rynnn=r_shape(nn,nnn)*sin(th(nn)+th_shape(nn,nnn));
                        dyy=(y(mm)+rymmm)-(y(nn)+rynnn);
                        im=round(dyy/Ly);
                        dyy=dyy-im*Ly;  % Periodic x
                        DDnm=(Dn(nn)+Dn(mm))/2;
                        if(abs(dyy)<Dnm)
                            rxmmm=r_shape(mm,mmm)*cos(th(mm)+th_shape(mm,mmm));
                            rxnnn=r_shape(nn,nnn)*cos(th(nn)+th_shape(nn,nnn));
                            dxx=(x(mm)+rxmmm)-(x(nn)+rxnnn);
                            dxx=dxx-round(dxx/Lx-im*gam)*Lx-im*gam*Lx;
                            ddnm=sqrt(dxx.^2+dyy.^2);
                            if(ddnm<DDnm)
                                num_bump_contacts = num_bump_contacts+1;
                                bb_contact_list(num_bump_contacts,:) = [nnn,mmm];
                            end
                        end
                    end
                end
                bb_contact_list = bb_contact_list(1:num_bump_contacts,:);
                nn_list = unique(bb_contact_list(:,1));
                mm_list = unique(bb_contact_list(:,2));
                setn = getSubset(nn_list);
                setm = getSubset(mm_list);
                combination = {};
                count_set = 0;
                for i=1:numel(setn)
                    for j=1:numel(setm)
                        count_set = count_set + 1;
                        combination{count_set,1} = getSign(numel(setn{1,i})) * getSign(numel(setm{1,j}));
                        combination{count_set,2} = setn{1,i};
                        combination{count_set,3} = setm{1,j};
                    end
                end
                if ~isempty(combination)
                    for i=1:numel(combination(:,1))
                        [A_analytical, A_monte_carlo] = calcArea(x,y,th,r_shape,th_shape,Dn,R2n,Lx,Ly,gam,nn,mm,combination{i,2},combination{i,3},debug);
                        A = A + combination{i,1} * A_analytical;
                        if debug
                            A_mc = A_mc + combination{i,1} * A_monte_carlo;
                        end
                    end
                end
                if debug
                    Alist = [Alist;nn,mm,A,A_mc];
                else
                    Alist = [Alist;nn,mm,A];
                end
            else
                if debug
                    Alist = [Alist;nn,mm,0,0];
                else
                    Alist = [Alist;nn,mm,0];
                end
            end
        end
    end
end

end