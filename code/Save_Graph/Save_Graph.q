// Save all the graphs relevant for the generation of reports and for prosperity
\d .automl

nodekeys:`function`inputs`outputs
i.Save_Graph_inputs  :"!"
i.Save_Graph_outputs :"!"
i.Save_Graph_function:{x}
Save_Graph:nodekeys!(i.Save_Graph_function;i.Save_Graph_inputs;i.Save_Graph_outputs)
