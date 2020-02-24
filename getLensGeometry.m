function [flag,a,ddnm,DDnm,c1,c2] = getLensGeometry(x,y,Dn,Lx,Ly,gam)
% c1 and c2 are the candidates of the intersecting point
Rn = Dn./2;
DDnm=(Dn(2)+Dn(1))/2;
dyy = y(2) - y(1);
im=round(dyy/Ly);
dyy=dyy-im*Ly;  % Periodic x
dxx = x(2) - x(1);
dxx=dxx-round(dxx/Lx-im*gam)*Lx-im*gam*Lx;
ddnm2 = dxx.^2+dyy.^2;
ddnm=sqrt(ddnm2);
if(ddnm<DDnm)
    flag = true;
    % get a
    a = sqrt((-ddnm + Rn(1) - Rn(2))*(-ddnm - Rn(1) + Rn(2))*(-ddnm + Rn(1) + Rn(2))*(ddnm + Rn(1) + Rn(2)))/ddnm;
    % ONLY WORKS FOR EQUAL SIZE BUMPS, also needs to handle periodic BCs
    % with deformation due to strain
    cy = y(1) + dyy/2 + (a/2)*(dxx/ddnm);
    cx = x(1) + dxx/2 - (a/2)*(dyy/ddnm);
    im = floor(cy/Ly);
    cx = mod(cx-im*(gam)*Lx,Lx);  % Periodic x
    cy = mod(cy,Ly);  % Periodic y
    c1 = [cx,cy];
    
    cy = y(1) + dyy/2 - (a/2)*(dxx/ddnm);
    cx = x(1) + dxx/2 + (a/2)*(dyy/ddnm);
    im = floor(cy/Ly);
    cx = mod(cx-im*(gam)*Lx,Lx);  % Periodic x
    cy = mod(cy,Ly);  % Periodic y
    c2 = [cx,cy];
else
    flag = false;
    a = 0;
    c1 = 0;
    c2 = 0;
end

end