\d .automl

loadfile`:code/customization/check.q

// Initialize model key within automl namespace
// needed for when keras or torch aren't installed
models.init:()

// Attempt to load keras/pytorch functionality
check.loadkeras[]
check.loadtorch[]
check.loadlatex[]
