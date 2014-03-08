<%
'-----EDIT THE MAILING DETAILS IN THIS SECTION-----
dim fromName, fromAddress, recipientName, recipientAddress, subject, body, sentTo

fromName        = "Web Master"
fromAddress     = "webmaster@funagrams.com"
recipientName   = "info"
recipientAddress= "info@funagrams.com"
subject         = "contact Us Form"
body            = "Form submitted: <br>Name: <b>" & Request.Form("name") & "</b><br>Email: <b>" & Request.Form("email") & "</b><br>Message: <b>" & Request.Form("messageText") & "</b>"


'-----YOU DO NOT NEED TO EDIT BELOW THIS LINE-----

sentTo = "NOBODY"
Set Mailer = Server.CreateObject("SMTPsvg.Mailer")
Mailer.FromName = fromName
Mailer.FromAddress = fromAddress
Mailer.RemoteHost = "mrelay.perfora.net"
if Mailer.AddRecipient (recipientName, recipientAddress) then
sentTo=recipientName & " (" & recipientAddress & ")"
end if
Mailer.Subject = subject
Mailer.BodyText = body
if Mailer.SendMail then
Response.Write "we will get back to you at the earliest"
else
Response.Write "error:" & Mailer.Response
end if
%>