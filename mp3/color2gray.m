function output = color2gray(im_rgb)  
    [HEIGHT, WIDTH, ~] = size(im_rgb);
    COLS = HEIGHT * WIDTH;
    VARS = 2 * HEIGHT * WIDTH - HEIGHT - WIDTH;
    
    channel = squeeze(im_rgb(:, :, 1));
    row_diffs = reshape(channel(1:end - 1, :) - channel(2:end, :), 1, []);
    col_diffs = reshape(channel(:, 1:end - 1) - channel(:, 2:end), 1, []);
    b = [row_diffs, col_diffs, channel(1, 1)]';
    
    channel = squeeze(im_rgb(:, :, 2));
    row_diffs = reshape(channel(1:end - 1, :) - channel(2:end, :), 1, []);
    col_diffs = reshape(channel(:, 1:end - 1) - channel(:, 2:end), 1, []);
    temp_b = [row_diffs, col_diffs, channel(1, 1)]';
    
    mix_mask = (abs(temp_b) - abs(b) > 0);
    b(mix_mask) = temp_b(mix_mask);
    
    channel = squeeze(im_rgb(:, :, 3));
    row_diffs = reshape(channel(1:end - 1, :) - channel(2:end, :), 1, []);
    col_diffs = reshape(channel(:, 1:end - 1) - channel(:, 2:end), 1, []);
    temp_b = [row_diffs, col_diffs, channel(1, 1)]';
    
    mix_mask = (abs(temp_b) - abs(b) > 0);
    b(mix_mask) = temp_b(mix_mask);
    
    indices = reshape(1:COLS, HEIGHT, WIDTH);
    
    cols_row = reshape([reshape(indices(1:end - 1, :), 1, []); reshape(indices(2:end, :), 1, [])], 1, []);
    cols_col = reshape([reshape(indices(:, 1:end - 1), 1, []); reshape(indices(:, 2:end), 1, [])], 1, []);
    
    rows = [kron(1:VARS, ones(1, 2)), VARS + 1];
    cols = [cols_row, cols_col, 1];
    vals = [reshape([ones(1, VARS); -ones(1, VARS)], 1, []), 1];
    
    A = sparse(rows, cols, vals, VARS + 1, COLS);
    
	output = reshape(A \ b, HEIGHT, WIDTH);
end

