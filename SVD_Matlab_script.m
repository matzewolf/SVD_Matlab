% Image Compression with Singular Value Decomposition (SVD).
%   This script uses the SVD for Image Compression, analyses the algorithm
%   (also with Information Theory) and visualizes the results.

close all; clear; clc;


%% Compression algorithm

% Original image matrix
Lena_org = imread('lena.bmp'); % in uint8
Lena = double(Lena_org); % in double

% SVD on the image
[U,S,V] = svd(Lena);

% Extract Singular Values (SVs)
singvals = diag(S);

% Determine to be saved SVs
c = 0.01; % change c to change quality
indices = find(singvals >= c * singvals(1)); % only SVs bigger than c times biggest SV

% Truncate U,S,V
U_red = U(:,indices);
S_red = S(indices,indices);
V_red = V(:,indices);

% Calculate compressed image
USV_red = U_red * S_red * V_red';
Lena_red = uint8(USV_red);

% Save compressed image
imwrite(Lena_red,'ReducedLena.bmp');


%% Analysis of the algorithm

% Size of the image
m = size(Lena,1);
n = size(Lena,2);
storage = m*n;
fprintf('Size of image is %d px by %d px, i.e. uses %d px of storage.\n',m,n,storage);

% SVs and reduced storage
r = length(singvals); % original number of SVs
r_red = length(indices); % to be saved number of SVs
r_max = floor(m*n/(m+n+1)); % maximum to be saved number of SVs for compression
storage_red = m*r_red + n*r_red + r_red;
fprintf('The smallest SV is chosen to be smaller than %d of the biggest SV.\n',c);
fprintf('Out of %d SVs, now only %d SVs are saved.\n',r,r_red);
fprintf('The maximum number of SVs for compression are %d SVs.\n',r_max);
fprintf('Thhe reduced storage now is %d px.\n',storage_red);

% Determine made error
error = 1 - sum(singvals(indices))/sum(singvals);
fprintf('The made error is %d.\n',error);
errorImage = Lena_org - Lena_red;

% Entropy
entropy_org = entropy(Lena_org);
entropy_red = entropy(Lena_red);


%% Relationship between selcted SVs and made error

numSVals = 1:10:r;
displayedError = [];

for i = numSVals
    % store S in a temporary matrix
    S_loop = S;
    % truncate S
    S_loop(i+1:end,:) = 0;
    S_loop(:,i+1:end) = 0;
    % construct Image using truncated S
    Lena_loop = U*S_loop*V';
    % compute error
    error_loop = 1 - sum(diag(S_loop))/sum(diag(S));
    % add error to display vector
    displayedError = [displayedError, error_loop];
end


%% Figures

figure('Name','Visualizations','units','normalized','outerposition',[0 0 1 1]);

% Original image
subplot(2,3,1)
imshow(uint8(Lena))
title('Original image')

% Histogram of original image
subplot(2,3,2)
imhist(Lena_org);
title('Histogram of original image')

% Compressed image
subplot(2,3,4)
imshow(uint8(Lena_red))
title('Compressed image')

% Histogram of compressed image
subplot(2,3,5)
imhist(Lena_red);
title('Histogram of compressed image')

% Error image
subplot(2,3,3)
imshow(uint8(errorImage))
title('Error image')

% Compression error over saved SVs
subplot(2,3,6)
plot(numSVals, displayedError)
xlabel('Number of saved Singular Values')
ylabel('Compression error')
title('Compression error over saved SVs')
