% writes a graph in PNG and PDF format
function [] = write_pdf(fn);

print(fn, '-dpng');
print(fn, '-dpdf');



