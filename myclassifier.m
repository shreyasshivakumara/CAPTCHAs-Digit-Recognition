function S = myclassifier(im)
% Function for taking an image containing three digits, which can be 0, 1
% or 2. Make a guess of these digits and return the guess.
% Results when run on 1200 given images:
% Average precision: 0.868333
% Elapsed time is 97.463905 seconds.

% Remove background and binarize:
T = 0.05;  % Use a quite extreme threshold value
BinImage = imbinarize(im,T);
BinImage = not(BinImage);
BinImage = medfilt2(BinImage, [1,1]);   % use a median

% Distance transform
Idist=bwdist(~BinImage);
IdistInv = -Idist;

% Apply mask and watershed
mask = imextendedmin(IdistInv,2);
IdistV2 = imimposemin(IdistInv, mask);
WS = watershed(IdistV2, 8);
WS(~BinImage) = 0;

% Labelling
[Ilabel] = bwlabel(WS, 8);

% Removing the items which are too small
Data=regionprops(Ilabel, 'Area', 'FilledArea', 'MajorAxisLength', 'MinorAxisLength', 'Perimeter');
Area = [Data.Area];
FilledArea = [Data.FilledArea];
MajorAxisLength = [Data.MajorAxisLength];
MinorAxisLength = [Data.MinorAxisLength];
Perimeter = [Data.Perimeter];

minArea = 50;
nrRows  = size(Data);
nrRows = nrRows(1);

Result = [];

% Finding insufficient circles
for row=1:nrRows
    if Area(row) > minArea
        if FilledArea(row) > 1.25*Area
            Result = [Result, 0];
        elseif MajorAxisLength(row) > 3*MinorAxisLength(row)
            Result = [Result, 1];
        elseif Perimeter(row) > 3*MajorAxisLength(row)
            Result = [Result, 2];
        else
            Result = [Result, 2];
        end
    end
end

% In case it's not possible to identify three objects.
while length(Result)<3
    % We were not able to detect three clear different objects (numbers).
    % Just return some random values.
    Result = [Result, floor(rand(1)*3)];
end

S = Result;
end

