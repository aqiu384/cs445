addpath vlfeat-0.9.19/
addpath vlfeat-0.9.19/toolbox/
vl_setup;

REF_PATH = './video1';
FRAMES_PATH = strcat(REF_PATH, '/frames/f%04d.jpg');
HOMOGRAPHY_PATH = strcat(REF_PATH, '/homographies/panorama.mat');
PANORAMA_PATH = strcat(REF_PATH, '/panorama.jpg');

% master_frames = [60, 180, 300, 420, 540];
% reference_frame = 300;
master_frames = [90, 270, 450, 630, 810];
reference_frame = 450;

master_trans = zeros(3, 3, 4);
master_pairs = [90, 270, 450, 630, 810
                270, 450, 450, 450, 630];
% master_pairs = [60, 180, 300, 420, 540;
%                 180, 300, 300, 300, 420];

output_x = [-651, 980];
output_y = [-51, 460];

for i = 1:length(master_pairs)
    I = imread(sprintf(FRAMES_PATH, master_pairs(2, i)));
    I_p = imread(sprintf(FRAMES_PATH, master_pairs(1, i)));
    master_trans(:, :, i) = auto_homography(I_p, I);
end

master_trans(:, :, 1) = master_trans(:, :, 2) * master_trans(:, :, 1);
master_trans(:, :, 5) = master_trans(:, :, 4) * master_trans(:, :, 5);
master_trans(:, :, 3) = eye(3);

M = ones(360, 480, 3);
output = zeros(output_y(2) - output_y(1) + 1, output_x(2) - output_x(1) + 1, 3);

for i = length(master_pairs):-1:1
    I_p = im2double(imread(sprintf(FRAMES_PATH, master_pairs(1, i))));
    T_p = maketform('projective', master_trans(:, :, i)');
    
    imt = imtransform(I_p, T_p, 'XData', output_x, 'YData', output_y);
    mast = imtransform(M, T_p, 'XData', output_x, 'YData', output_y);
    output = output .* (1 - mast) + imt .* mast;
end

save(HOMOGRAPHY_PATH, 'master_trans');
imwrite(output, PANORAMA_PATH);
imshow(output);
