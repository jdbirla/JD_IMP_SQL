# JD_Spool

### JD Spool file information
- Using this scripts we can generate spool file in oracle 
- JD_Spool_Practice.sql this a sample script file which can generate spool file in oracle 
- Spool_guide.txt has important commands which can be used in generating spool file.
----
### Oracle SQL Plus Important commands.
<table class="cellalignment663" title="SQL*Plus Command Summary" summary="2 column table of SQL*Plus commands, cross referenced to the command page , and a description of the command. The column headings are, Command, and Description." dir="ltr">
<thead>
<tr class="cellalignment654">
<th class="cellalignment664" id="r1c1-t3">Command</th>
<th class="cellalignment664" id="r1c2-t3">Description</th>
</tr>
</thead>
<tbody>
<tr class="cellalignment654">
<td class="cellalignment660" id="r2c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve002.htm#i2696724">@ (at sign)</a></p>
</td>
<td class="cellalignment660" headers="r2c1-t3 r1c2-t3">Runs SQL*Plus statements in the specified script. The script can be called from the local file system or from a web server.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r3c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve003.htm#i2696759">@@ (double at sign)</a></p>
</td>
<td class="cellalignment660" headers="r3c1-t3 r1c2-t3">Runs a script. This command is similar to the @ (at sign) command It is useful for running nested scripts because it looks for the specified script in the same path as the calling script.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r4c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve004.htm#i2696794">/ (slash)</a></p>
</td>
<td class="cellalignment660" headers="r4c1-t3 r1c2-t3">Executes the SQL command or PL/SQL block.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r5c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve005.htm#BACGJIHF">ACCEPT</a></p>
</td>
<td class="cellalignment660" headers="r5c1-t3 r1c2-t3">Reads a line of input and stores it in a given substitution variable.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r6c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve006.htm#i2673434">APPEND</a></p>
</td>
<td class="cellalignment660" headers="r6c1-t3 r1c2-t3">Adds specified text to the end of the current line in the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r7c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve007.htm#i2696879">ARCHIVE LOG</a></p>
</td>
<td class="cellalignment660" headers="r7c1-t3 r1c2-t3">Displays information about redo log files.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r8c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve008.htm#i2696913">ATTRIBUTE</a></p>
</td>
<td class="cellalignment660" headers="r8c1-t3 r1c2-t3">Specifies display characteristics for a given attribute of an Object Type column, and lists the current display characteristics for a single attribute or all attributes.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r9c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve009.htm#i2696939">BREAK</a></p>
</td>
<td class="cellalignment660" headers="r9c1-t3 r1c2-t3">Specifies where and how formatting will change in a report, or lists the current break definition.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r10c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve010.htm#i2697039">BTITLE</a></p>
</td>
<td class="cellalignment660" headers="r10c1-t3 r1c2-t3">Places and formats a specified title at the bottom of each report page, or lists the current BTITLE definition.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r11c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve011.htm#i2673882">CHANGE</a></p>
</td>
<td class="cellalignment660" headers="r11c1-t3 r1c2-t3">Changes text on the current line in the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r12c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve012.htm#i2697099">CLEAR</a></p>
</td>
<td class="cellalignment660" headers="r12c1-t3 r1c2-t3">Resets or erases the current clause or setting for the specified option, such as BREAKS or COLUMNS.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r13c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve013.htm#i2697128">COLUMN</a></p>
</td>
<td class="cellalignment660" headers="r13c1-t3 r1c2-t3">Specifies display characteristics for a given column, or lists the current display characteristics for a single column or for all columns.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r14c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve014.htm#i2697257">COMPUTE</a></p>
</td>
<td class="cellalignment660" headers="r14c1-t3 r1c2-t3">Calculates and prints summary lines, using various standard computations, on subsets of selected rows, or lists all COMPUTE definitions.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r15c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve015.htm#i2697450">CONNECT</a></p>
</td>
<td class="cellalignment660" headers="r15c1-t3 r1c2-t3">Connects a given user to Oracle Database.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r16c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve016.htm#i2675035">COPY</a></p>
</td>
<td class="cellalignment660" headers="r16c1-t3 r1c2-t3">Copies results from a query to a table in the same or another database.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r17c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve017.htm#i2697507">DEFINE</a></p>
</td>
<td class="cellalignment660" headers="r17c1-t3 r1c2-t3">Specifies a substitution variable and assigns it a CHAR value, or lists the value and variable type of a single variable or all variables.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r18c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve018.htm#i2675265">DEL</a></p>
</td>
<td class="cellalignment660" headers="r18c1-t3 r1c2-t3">Deletes one more lines of the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r19c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve019.htm#i2697562">DESCRIBE</a></p>
</td>
<td class="cellalignment660" headers="r19c1-t3 r1c2-t3">Lists the column definitions for the specified table, view, or synonym or the specifications for the specified function procedure.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r20c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve020.htm#i2697902">DISCONNECT</a></p>
</td>
<td class="cellalignment660" headers="r20c1-t3 r1c2-t3">Commits pending changes to the database and logs the current user off Oracle Database, but does not exit SQL*Plus.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r21c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve021.htm#i2675783">EDIT</a></p>
</td>
<td class="cellalignment660" headers="r21c1-t3 r1c2-t3">Invokes an operating system text editor on the contents of the specified file or on the contents of the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r22c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve022.htm#i2697931">EXECUTE</a></p>
</td>
<td class="cellalignment660" headers="r22c1-t3 r1c2-t3">Executes a single PL/SQL statement.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r23c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve023.htm#i2697968">EXIT</a></p>
</td>
<td class="cellalignment660" headers="r23c1-t3 r1c2-t3">Terminates SQL*Plus and returns control to the operating system.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r24c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve024.htm#i2675990">GET</a></p>
</td>
<td class="cellalignment660" headers="r24c1-t3 r1c2-t3">Loads an operating system file into the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r25c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve025.htm#i2697999">HELP</a></p>
</td>
<td class="cellalignment660" headers="r25c1-t3 r1c2-t3">Accesses the SQL*Plus command-line help system.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r26c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve026.htm#i2676105">HOST</a></p>
</td>
<td class="cellalignment660" headers="r26c1-t3 r1c2-t3">Executes an operating system command without leaving SQL*Plus.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r27c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve027.htm#i2676161">INPUT</a></p>
</td>
<td class="cellalignment660" headers="r27c1-t3 r1c2-t3">Adds one or more new lines after the current line in the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r28c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve028.htm#i2698066">LIST</a></p>
</td>
<td class="cellalignment660" headers="r28c1-t3 r1c2-t3">Lists one or more lines of the buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r29c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve029.htm#i2676330">PASSWORD</a></p>
</td>
<td class="cellalignment660" headers="r29c1-t3 r1c2-t3">Enables a password to be changed without echoing the password on an input device.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r30c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve030.htm#i2698126">PAUSE</a></p>
</td>
<td class="cellalignment660" headers="r30c1-t3 r1c2-t3">Displays the specified text, then waits for the user to press Return.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r31c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve031.htm#i2698143">PRINT</a></p>
</td>
<td class="cellalignment660" headers="r31c1-t3 r1c2-t3">Displays the current value of a bind variable.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r32c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve032.htm#i2698182">PROMPT</a></p>
</td>
<td class="cellalignment660" headers="r32c1-t3 r1c2-t3">Sends the specified message to the user's screen.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r33c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve023.htm#i2697968">EXIT</a></p>
</td>
<td class="cellalignment660" headers="r33c1-t3 r1c2-t3">Terminates SQL*Plus and returns control to the operating system QUIT is identical to EXIT.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r34c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve033.htm#i2698238">RECOVER</a></p>
</td>
<td class="cellalignment660" headers="r34c1-t3 r1c2-t3">Performs media recovery on one or more tablespaces, one or more datafiles, or the entire database.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r35c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve034.htm#i2698336">REMARK</a></p>
</td>
<td class="cellalignment660" headers="r35c1-t3 r1c2-t3">Begins a comment in a script.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r36c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve035.htm#i2698377">REPFOOTER</a></p>
</td>
<td class="cellalignment660" headers="r36c1-t3 r1c2-t3">Places and formats a specified report footer at the bottom of each report, or lists the current REPFOOTER definition.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r37c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve036.htm#i2698435">REPHEADER</a></p>
</td>
<td class="cellalignment660" headers="r37c1-t3 r1c2-t3">Places and formats a specified report header at the top of each report, or lists the current REPHEADER definition.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r38c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve037.htm#i2698485">RUN</a></p>
</td>
<td class="cellalignment660" headers="r38c1-t3 r1c2-t3">Lists and runs the SQL command or PL/SQL block currently stored in the SQL buffer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r39c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve038.htm#i2677055">SAVE</a></p>
</td>
<td class="cellalignment660" headers="r39c1-t3 r1c2-t3">Saves the contents of the buffer in an operating system file (a script).</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r40c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve039.htm#i2698538">SET</a></p>
</td>
<td class="cellalignment660" headers="r40c1-t3 r1c2-t3">Sets a system variable to alter the SQL*Plus environment for your current session.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r41c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve041.htm#i2699447">SHOW</a></p>
</td>
<td class="cellalignment660" headers="r41c1-t3 r1c2-t3">Shows the value of a SQL*Plus system variable or the current SQL*Plus environment.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r42c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve042.htm#i2699551">SHUTDOWN</a></p>
</td>
<td class="cellalignment660" headers="r42c1-t3 r1c2-t3">Shuts down a currently running Oracle Database instance.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r43c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve043.htm#i2683777">SPOOL</a></p>
</td>
<td class="cellalignment660" headers="r43c1-t3 r1c2-t3">Stores query results in an operating system file and, optionally, sends the file to a printer.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r44c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve044.htm#BACJJHDA">START</a></p>
</td>
<td class="cellalignment660" headers="r44c1-t3 r1c2-t3">Runs the SQL statements in the specified script. The script can be called from a local file system or a web server in SQL*Plus command-line.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r45c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve045.htm#i2699631">STARTUP</a></p>
</td>
<td class="cellalignment660" headers="r45c1-t3 r1c2-t3">Starts an Oracle Database instance and optionally mounts and opens a database.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r46c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve046.htm#i2684072">STORE</a></p>
</td>
<td class="cellalignment660" headers="r46c1-t3 r1c2-t3">Saves attributes of the current SQL*Plus environment in an operating system script.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r47c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve047.htm#i2699704">TIMING</a></p>
</td>
<td class="cellalignment660" headers="r47c1-t3 r1c2-t3">Records timing data for an elapsed period of time, lists the current timer's title and timing data, or lists the number of active timers.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r48c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve048.htm#i2699732">TTITLE</a></p>
</td>
<td class="cellalignment660" headers="r48c1-t3 r1c2-t3">Places and formats a specified title at the top of each report page, or lists the current TTITLE definition.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r49c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve049.htm#i2699781">UNDEFINE</a></p>
</td>
<td class="cellalignment660" headers="r49c1-t3 r1c2-t3">Deletes one or more substitution variables that you defined either explicitly (with the DEFINE command) or implicitly (with an argument to the START command).</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r50c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve050.htm#i2699801">VARIABLE</a></p>
</td>
<td class="cellalignment660" headers="r50c1-t3 r1c2-t3">Declares a bind variable that can be referenced in PL/SQL.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r51c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve051.htm#i2700032">WHENEVER OSERROR</a></p>
</td>
<td class="cellalignment660" headers="r51c1-t3 r1c2-t3">Exits SQL*Plus if an operating system command generates an error.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r52c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve052.htm#i2700066">WHENEVER SQLERROR</a></p>
</td>
<td class="cellalignment660" headers="r52c1-t3 r1c2-t3">Exits SQL*Plus if a SQL command or PL/SQL block generates an error.</td>
</tr>
<tr class="cellalignment654">
<td class="cellalignment660" id="r53c1-t3" headers="r1c1-t3">
<p class="synopsis"><a href="ch_twelve053.htm#BGBGDADB">XQUERY</a></p>
</td>
<td class="cellalignment660" headers="r53c1-t3 r1c2-t3">Runs an XQuery 1.0 statement.</td>
</tr>
</tbody>
</table>

---
