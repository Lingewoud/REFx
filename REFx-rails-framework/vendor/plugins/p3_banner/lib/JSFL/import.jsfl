// Init
var config = {
	documentName		: 'file:///Users/shaman/Desktop/JSFL/input/fla/Alto300x250.fla', 	//Absolute path to the input FLA file
	outputBasePath		: 'file:///Users/shaman/Desktop/JSFL/', 								//Absolute path to the output dir
	jobID 				: '0879ab', 																//PHP's job ID, postfixed to the outputBasePath, use to match log entries to jobs
	outputFolder		: 'output/',															//Where should the script write the swf, image and xml files, relative to the outputBasePath
	outputFileName 		: 'test',																//Basename for .fla and .swf output files
	
	logFilePath			: '',																	//Path where the log file will be written, relative to script dir
	logFileName			: 'log.txt',															//Log filename
	
	gifDuration			: 10,																	//Duration in seconds
	
	logToFile 			: true, 																//Whether to log to a file
	logToIDE 			: false, 																//Whether to log to the IDE's output panel
	libDir 				: 'lib/', 																//Static JSFL library directory relative to script dir	
}

var startTime 				= new Date();
var scriptPath 				= fl.scriptURI;
var scriptPathParts 		= scriptPath.split('/');
var scriptName 				= scriptPathParts[scriptPathParts.length-1];
var scriptDir 				= scriptPath.split(scriptName)[0];

//Prepare filepaths
FLfile.createFolder( config.basePath+config.outputFolder + config.jobID);

config.basePath				= scriptDir;
config.libDir 				= config.basePath + config.libDir;
config.logFilePath			= config.basePath+config.logFileName;
config.outputFilePath 		= config.outputBasePath+config.outputFolder + config.jobID + '/';
config.profileFilePath 		= config.basePath+config.outputFolder + 'png.xml';
config.outputFLAFilePath 	= config.outputFilePath + config.outputFileName +'.fla';
config.outputSWFFilePath 	= config.outputFilePath + config.outputFileName +'.swf';
config.outputStatusPath 	= config.outputFilePath +'status.txt';

//Load Modules
fl.runScript(config.libDir+'Utils.jsfl');
fl.runScript(config.libDir+'Logger.jsfl');
fl.runScript(config.libDir+'ImportBO.jsfl');
fl.runScript(config.libDir+'ExportFile.jsfl');
fl.runScript(config.libDir+'ExportProfile.jsfl');
fl.runScript(config.libDir+'ObjectFindAndSelect.jsfl');

// Start
Utils.initLogger(config,scriptName);

var srcFile = Utils.loadFLA(this.config.documentName);

ImportBO.init(config);

FLfile.createFolder(config.outputFilePath);

try {
	var success = ImportBO.importXML( true, true);
} catch (e) {
	Logger.log( e, Logger.CRITICAL );
}

srcFile.close( false );


var procString = '';

if ( success ) {
	procString = 'Processing completed successfully';
	Logger.log( procString );
	FLfile.write(config.outputStatusPath, procString +"\n","append");
}
else
{
	procString = 'Errors encountered, operation may have failed';
	Logger.log( procString,Logger.CRITICAL );
	FLfile.write(config.outputStatusPath, procString +"\n","append");
}

procString = 'Script exiting ('+((new Date().getTime()-startTime.getTime())/1000)+'s)';

Logger.log( procString );
FLfile.write( config.outputStatusPath, procString +"\n", "append" );

//end



