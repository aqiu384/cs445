output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

input_x = [-121, 600];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

COMPUTE_BACKGROUND = false;
NUM_FRAMES = 900;

master_frames = [90, 270, 450, 630, 810];
master_deps = NUM_FRAMES / length(master_frames);

index = 1;

load('./video1/homographies/panorama.mat');
load('./video1/homographies/movie.mat');

I = imread('./video1/background.jpg');
figure();

for i = 1:length(master_frames)
    T = master_trans(:, :, i);

    for j = 1:master_deps
        disp(index)

        T_inv = maketform('projective', inv(T * movie_trans(:, :, index))');

        imt = imtransform(I, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);
        imwrite(imt, sprintf('./video1/wider/f%04d.jpg', index));
        imshow(imt);

        index = index + 1;
    end
end