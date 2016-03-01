function output = pyramidBlend(im_s, mask_s, im_background)
    LEVELS = 6;
    SIGMA = 1;
    levels = cell(1, LEVELS);
    sizes = zeros(2, LEVELS);
    
    img1 = im2double(im_s);
    img2 = im2double(im_background);
    mask = repmat(im2double(mask_s), [1, 1, 3]);
    
    temp1 = img1;
    temp2 = img2;
    
    for i = 1:LEVELS
        temp1 = imgaussfilt(img1, SIGMA);
        temp2 = imgaussfilt(img2, SIGMA);
        
        levels{i} = (img1 - temp1) .* mask + (img2 - temp2) .* (1 - mask);

        [ROWS, COLS, ~] = size(temp1);
        sizes(1, i) = ROWS;
        sizes(2, i) = COLS;
        
        img1 = temp1(1:2:end, 1:2:end, :);
        img2 = temp2(1:2:end, 1:2:end, :);
        
        mask = imgaussfilt(mask, SIGMA);
        mask = mask(1:2:end, 1:2:end, :);
    end
    
    output = img1 .* mask + img2 .* (1 - mask);
    
    for i = LEVELS:-1:1
        output = imresize(output, sizes(:, i)') + levels{i};
    end
end

