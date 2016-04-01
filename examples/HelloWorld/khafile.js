var project = new Project('Hello World');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('kala');
return project;
