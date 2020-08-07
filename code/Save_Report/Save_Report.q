// Save a latex/python generated report summarising the process of reaching the users final model
\d .automl

nodekeys:`function`inputs`outputs
i.Save_Report_inputs  :"!"
i.Save_Report_outputs :"!"
i.Save_Report_function:{x}
Save_Report:nodekeys!(i.Save_Report_function;i.Save_Report_inputs;i.Save_Report_outputs)
