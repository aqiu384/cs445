function output = toy_reconstruct(toy_image)
    [HEIGHT, WIDTH] = size(toy_image);
    COLS = HEIGHT * WIDTH;
    VARS = 2 * HEIGHT * WIDTH - HEIGHT - WIDTH;
    
    row_diffs = reshape(toy_image(1:end - 1, :) - toy_image(2:end, :), 1, []);
    col_diffs = reshape(toy_image(:, 1:end - 1) - toy_image(:, 2:end), 1, []);
    
    indices = reshape(1:COLS, HEIGHT, WIDTH);
    
    cols_row = reshape([reshape(indices(1:end - 1, :), 1, []); reshape(indices(2:end, :), 1, [])], 1, []);
    cols_col = reshape([reshape(indices(:, 1:end - 1), 1, []); reshape(indices(:, 2:end), 1, [])], 1, []);
    
    rows = [kron(1:VARS, ones(1, 2)), VARS + 1];
    cols = [cols_row, cols_col, 1];
    vals = [reshape([ones(1, VARS); -ones(1, VARS)], 1, []), 1];
    
    A = sparse(rows, cols, vals, VARS + 1, COLS);
    b = [row_diffs, col_diffs, toy_image(1, 1)]';
    
	output = reshape(A \ b, HEIGHT, WIDTH);
end

