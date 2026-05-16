Started by user Jenkins Admin
Lightweight checkout support not available, falling back to full checkout.
Checking out git https://github.com/MuhammadJaffar52/devops-infrastructure.git https://github.com/MuhammadJaffar52/devops-infrastructure.git into /var/jenkins_home/workspace/frontend-pipeline@script/f8a2478c3758c31a96c254659b9a4766985b5f3b7de34837cb4ddb42d3eb49c6 to read jenkins/pipelines/frontend.Jenkinsfile
The recommended git tool is: git
using credential github-token
using credential github-token
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/frontend-pipeline@script/f8a2478c3758c31a96c254659b9a4766985b5f3b7de34837cb4ddb42d3eb49c6/.git # timeout=10
Fetching changes from 2 remote Git repositories
 > git config remote.origin.url https://github.com/MuhammadJaffar52/devops-infrastructure.git # timeout=10
Fetching upstream changes from https://github.com/MuhammadJaffar52/devops-infrastructure.git
 > git --version # timeout=10
 > git --version # 'git version 2.47.3'
using GIT_ASKPASS to set credentials 
 > git fetch --tags --force --progress -- https://github.com/MuhammadJaffar52/devops-infrastructure.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin1.url https://github.com/MuhammadJaffar52/devops-infrastructure.git # timeout=10
Fetching upstream changes from https://github.com/MuhammadJaffar52/devops-infrastructure.git
using GIT_ASKPASS to set credentials 
 > git fetch --tags --force --progress -- https://github.com/MuhammadJaffar52/devops-infrastructure.git +refs/heads/*:refs/remotes/origin1/* # timeout=10
Seen branch in repository origin/main
Seen branch in repository origin1/main
Seen 2 remote branches
 > git show-ref --tags -d # timeout=10
Checking out Revision ea3f10133c346d1641859dcf440e60dbf1496aa2 (origin/main, origin1/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f ea3f10133c346d1641859dcf440e60dbf1496aa2 # timeout=10
Commit message: "pipeline fixed"
 > git rev-list --no-walk 89f75f769ebd31b8f05209f1866068665c4f93ff # timeout=10
 > git rev-list --no-walk 89f75f769ebd31b8f05209f1866068665c4f93ff # timeout=10
org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 225: illegal string body character after dollar sign;
   solution: either escape a literal dollar sign "\$5" or bracket the value expression "${5}" @ line 225, column 46.
                    eval echo \\$${params.A
                                 ^

1 error

	at org.codehaus.groovy.control.ErrorCollector.failIfErrors(ErrorCollector.java:309)
	at org.codehaus.groovy.control.ErrorCollector.addFatalError(ErrorCollector.java:149)
	at org.codehaus.groovy.control.ErrorCollector.addError(ErrorCollector.java:119)
	at org.codehaus.groovy.control.ErrorCollector.addError(ErrorCollector.java:131)
	at org.codehaus.groovy.control.SourceUnit.addError(SourceUnit.java:349)
	at org.codehaus.groovy.antlr.AntlrParserPlugin.transformCSTIntoAST(AntlrParserPlugin.java:220)
	at org.codehaus.groovy.antlr.AntlrParserPlugin.parseCST(AntlrParserPlugin.java:191)
	at org.codehaus.groovy.control.SourceUnit.parse(SourceUnit.java:233)
	at org.codehaus.groovy.control.CompilationUnit$1.call(CompilationUnit.java:189)
	at org.codehaus.groovy.control.CompilationUnit.applyToSourceUnits(CompilationUnit.java:966)
	at org.codehaus.groovy.control.CompilationUnit.doPhaseOperation(CompilationUnit.java:626)
	at org.codehaus.groovy.control.CompilationUnit.processPhaseOperations(CompilationUnit.java:602)
	at org.codehaus.groovy.control.CompilationUnit.compile(CompilationUnit.java:579)
	at groovy.lang.GroovyClassLoader.doParseClass(GroovyClassLoader.java:323)
	at groovy.lang.GroovyClassLoader.parseClass(GroovyClassLoader.java:293)
	at PluginClassLoader for script-security//org.jenkinsci.plugins.scriptsecurity.sandbox.groovy.GroovySandbox$Scope.parse(GroovySandbox.java:162)
	at PluginClassLoader for workflow-cps//org.jenkinsci.plugins.workflow.cps.CpsGroovyShell.doParse(CpsGroovyShell.java:202)
	at PluginClassLoader for workflow-cps//org.jenkinsci.plugins.workflow.cps.CpsGroovyShell.reparse(CpsGroovyShell.java:186)
	at PluginClassLoader for workflow-cps//org.jenkinsci.plugins.workflow.cps.CpsFlowExecution.parseScript(CpsFlowExecution.java:670)
	at PluginClassLoader for workflow-cps//org.jenkinsci.plugins.workflow.cps.CpsFlowExecution.start(CpsFlowExecution.java:616)
	at PluginClassLoader for workflow-job//org.jenkinsci.plugins.workflow.job.WorkflowRun.run(WorkflowRun.java:344)
	at hudson.model.ResourceController.execute(ResourceController.java:97)
	at hudson.model.Executor.run(Executor.java:456)
Finished: FAILURE
