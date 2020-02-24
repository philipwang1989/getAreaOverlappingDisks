function A = getCircularSegmentArea(D,a)

temp = sqrt(D*D-a*a);
A = 0.25 * (D*D*atan(a / temp) - a*temp) ;

end