var project = new Project('Text');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('kala');
return project;
