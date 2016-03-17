output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

input_x = [1, 480];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

NUM_FRAMES = 10;
STEP_SIZE = 1;
OFFSET = 1;

LENGTH_I = 10;
LENGTH_J = 90;

master_frames = [90, 90, 270, 270, 450, 450, 630, 630, 810, 810];

load('./homographies/panorama.mat');
load('./homographies/movie.mat');

medians_i = zeros(output_height, output_width, 3, LENGTH_I);
medians_j = zeros(output_height, output_width, 3, LENGTH_J);

index = 1;
figure();

M = ones(input_height, input_width, 3);

for i = 1:LENGTH_I
    T = master_trans(:, :, ceil(i/2));

    for j = 1:LENGTH_J
        disp(index)

        I_p = im2double(imread(sprintf('frames/f%04d.jpg', index))) + OFFSET;
        T_p = maketform('projective', (T * movie_trans(:, :, index))');
        
        index = index + 1;
        
        imt = imtransform(I_p, T_p, 'XData', output_x, 'YData', output_y);
        wt = imtransform(M, T_p, 'XData', output_x, 'YData', output_y);
        imt = imt ./ wt;
        
        medians_j(:, :, :, j) = imt;
        imshow(imt - 1);
    end
    
    medians_j(medians_j < OFFSET) = NaN;
    medians_i(:, :, :, i) = nanmedian(medians_j, 4);
end

output = nanmedian(medians_i, 4);
output = output - OFFSET;
output(isnan(output)) = 0;

imwrite(output, './background2/test900.jpg');
imshow(output);
