var project = new Project('Timer');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('kala');
return project;
