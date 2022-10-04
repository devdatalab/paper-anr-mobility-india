function [] = mob_sc_cohort_graph(gen_mob, sc_mob, ystr, graph_fn)

  cohorts = [1960 1970 1980 1990]';
  hold off
  plot(cohorts, gen_mob(:, 1), 'k')
  hold on
  plot(cohorts, gen_mob(:, 2), 'k')
  plot(cohorts, sc_mob(:, 1), 'k--')
  plot(cohorts, sc_mob(:, 2), 'k--')
  xlabel('Birth Cohort');
  ylabel(ystr);
  ylim([0 1]);
  f = strcat('~/iec1/output/pn/', graph_fn);
  print(f, '-dpng');
  copyfile(strcat(f, '.png'), '~/public_html/png');
