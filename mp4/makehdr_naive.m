function makehdr_naive()
    SIZE = 255;
    COUNT = 3;

    WEIGHTS = [24, 60, 120, 205, 553];
    IMAGES = zeros(SIZE, SIZE, 3, COUNT);
    
    IMAGE_FILES = {
        './inputs/0024.jpg'
        './inputs/0060.jpg'
        './inputs/0120.jpg'
        './inputs/0205.jpg'
        './inputs/0553.jpg'
    };
    
    for i = 1:COUNT
        IMAGES(:, :, :, i) = WEIGHTS(i) * imresize(im2double(imread(IMAGE_FILES{i})), [SIZE, SIZE], 'bilinear');
    end
    
    disp(size(squeeze(IMAGES(:, :, 1, :))));

    naive = sum(IMAGES, 4) / COUNT;
    imshow(mat2gray(naive));
end
