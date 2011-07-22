function [rmin rmax cmin cmax cropped] = bbox(img)
%BBOX(IMG,TYPE)
%   Given the 3D-image IMG and its TYPE, retrieve the bounding box with the horizontal
%   minimum and maximum values. The effect of the type of the image is not implemented
%   yet. Hence, if the image is of type binary, just write any string when
%   calling this function.
%
%   Returns [RMIN RMAX CMIN CMAX CROPPED] where
%
%   CMIN: horizontal minimum value
%   CMAX: horizontal maximum value
%   RMIN: vertical minimum value
%   RMAX: vertical maximum value
%   CROPPED: the resulting image

[r c] = find(1-sign(img(:,:,1)));
rmin = min(r);
rmax = max(r);
cmin = min(c);
cmax = max(c);
cropped = img(rmin:rmax,cmin:cmax);