load('./homographies/panorama.mat');
load('./homographies/movie.mat');

output_x = [-651, 980];
output_y = [-51, 460];

input_x = [1, 480];
input_y = [1, 360];

I = imread('./frames/f0001.jpg');
T = maketform('projective', (master_trans(:, :, 1) * movie_trans(:, :, 1))');
T_inv = maketform('projective', inv(master_trans(:, :, 1) * movie_trans(:, :, 1))');

imt = imtransform(I, T, 'XData', output_x, 'YData', output_y);
imt_inv = imtransform(imt, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);

figure();
imshow(I);
figure()
imshow(imt_inv);
