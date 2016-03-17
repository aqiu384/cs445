function output = feather_overlay(background_file, foreground_file, clip_bottom, clip_right, sigma)
    background = double(imread(background_file));
    foreground = double(imrotate(imread(foreground_file), 180));
    foreground = foreground(1:end - clip_bottom, 1:end - clip_right, :);
        
    [b_h, b_w, ~] = size(background);
    [f_h, f_w, ~] = size(foreground);
    
    m_r = floor((b_h - f_h) / 2);
    m_c = floor((b_w - f_w) / 2);
    
    mask = zeros(size(background));
    new_ground = zeros(size(background));
    
    offset = 2 * (sigma + 1);
    
    mask(m_r + offset:m_r + f_h - 2 * offset, m_c + offset:m_c + f_w - 2 * offset, :) = 1;
    new_ground(m_r:m_r + f_h - 1, m_c:m_c + f_w - 1, :) = foreground;
    
    mask = imgaussfilt(mask, sigma);
    output = uint8(new_ground .* mask + background .* (1 - mask));
    imshow(output);
end

