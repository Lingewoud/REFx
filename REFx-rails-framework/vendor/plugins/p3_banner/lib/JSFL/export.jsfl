// Init
var config = {
	documentName		: 'file:///Users/shaman/Desktop/JSFL/input/fla/Alto300x250.fla', 	//Absolute path to the input FLA file
	outputBasePath		: 'file:///Users/shaman/Desktop/JSFL/', 								//Absolute path to the output dir
	jobID 				: '004d', 																//PHP's job ID, postfixed to the outputBasePath, use to match log entries to jobs
	outputFolder		: 'output/',															//Where should the script write the swf, image and xml files, relative to the outputBasePath
	outputFileName 		: 'out',																//Basename for .fla and .swf output files
	
	logFilePath			: '',																	//Path where the log file will be written, relative to script dir
	logFileName			: 'log.txt',															//Log filename
	
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

//Load Modules
fl.runScript(config.libDir+'Utils.jsfl');
fl.runScript(config.libDir+'Logger.jsfl');
fl.runScript(config.libDir+'ExportBO.jsfl');
fl.runScript(config.libDir+'ExportFile.jsfl');
fl.runScript(config.libDir+'ExportProfile.jsfl');
fl.runScript(config.libDir+'ObjectFindAndSelect.jsfl');
			
// Start
fl.outputPanel.clear();
Utils.initLogger(config,scriptName);

FLfile.createFolder(config.outputFilePath);

srcFile = Utils.loadFLA(this.config.documentName);

ExportBO.init(config);

try {
	var success = ExportBO.exportXMLAndImages( false );
} catch (e) {
	Logger.log( e, Logger.CRITICAL );
}
		
srcFile.close( false );


if ( success )
{
Logger.log( 'Processing completed successfully' );
}
else
{
Logger.log( 'Errors encountered, operation may have failed',Logger.CRITICAL );
}

//end
Logger.log( 'Script exiting ('+((new Date().getTime()-startTime.getTime())/1000)+'s)' );

