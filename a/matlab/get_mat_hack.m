% hack to get interior part of a 3-dimensional matrix
function p = get_mat_hack(m)

  p = m(:);
  p = [p(1:4) p(5:8)];
