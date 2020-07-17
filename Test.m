clear;

im = imread(sprintf('C:/Users/Shivakumara/Desktop/UPPSALA/Period 2/Computer Assisted Image Analysis I/lab5/imagedata/train_0118.png'));

% Remove background and binarize:
T = 0.05;  % Use a quite extreme threshold value
BinImage = imbinarize(im,T);
BinImage = not(BinImage);
BinImage = medfilt2(BinImage, [1,1]);   % use a median

figure(1)
subplot(1,2,1)
imshow(im)
title('Original Image')
subplot(1,2,2)
imshow(BinImage)
title('Binary Image')

% Distance transform
Idist=bwdist(~BinImage);
IdistInv = -Idist;

% Apply mask and watershed
mask = imextendedmin(IdistInv,2);
IdistV2 = imimposemin(IdistInv, mask);
WS = watershed(IdistV2, 8);
WS(~BinImage) = 0;

nb = 8;   % The neighborhood used for labeling in the bwlabel function
[Ilabel, numItems] = bwlabel(WS, nb);

figure(2);
subplot(2,2,1)
imshow(mat2gray(IdistInv));
title('Distance transform')
subplot(2,2,2)
imshow(mat2gray(WS));
title('Watershed transform')
subplot(2,2,4)
imshow(label2rgb(Ilabel, 'spring')); 
title(['Segmented image. Number of items: ', num2str(numItems)]);

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


