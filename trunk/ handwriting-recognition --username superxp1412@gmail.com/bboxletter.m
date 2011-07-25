function [rmin rmax cmin cmax cropped] = bboxletter(img, startColumn)
%BBOX(IMG,TYPE)
%   Given a binary image containing text returns the boundary of the first
%   letter which is located right to the startColumn
%
%   Returns [RMIN RMAX CMIN CMAX] where
%
%   CMIN: horizontal minimum value
%   CMAX: horizontal maximum value
%   RMIN: vertical minimum value
%   RMAX: vertical maximum value

%If start column is not specified set it to leftmost pixel 
if nargin < 2
    startColumn = 1;
end

%If there are no letters left or function did not work correctly, cmin or
%cmax would -1
cmin = -1;
cmax = -1;
rmin = -1;
rmax = -1;
cropped = [];

%Get image width
imWidth = size(img,2);
%Continue until we hit a letter
for i = startColumn : imWidth
    if sum(img(:,i)) ~= 0
        cmin = i;
        break;
    end
end


%No letter found
if cmin == -1
    return;
end

%Set cmax to the right end of the image
cmax = imWidth;

%Continue until the letter ends
for i = cmin : imWidth
    if sum(img(:,i)) == 0
        cmax = i;
        break;
    end
end

[r ~] = find(img(:,cmin:cmax));
rmin = min(r);
rmax = max(r);

cropped = img(rmin:rmax,cmin:cmax);