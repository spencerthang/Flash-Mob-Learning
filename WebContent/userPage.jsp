<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="uk.ac.cam.grpproj.lima.flashmoblearning.*,uk.ac.cam.grpproj.lima.flashmoblearning.database.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<%
		if(session.getAttribute(Attribute.USERID)==null){
			//session invalid
			response.sendRedirect("login.jsp");
			return;
		}
		if(session.getAttribute(Attribute.PRIVILEGE)==null||
				!session.getAttribute(Attribute.PRIVILEGE).equals("admin")){
			response.sendRedirect("landing.jsp");
			return;
		}
		String uid = request.getParameter("uid");
		Long userID = 0L;
		
		if(uid==null){
			response.sendRedirect("userList.jsp");
			return;
		}
		userID = Long.parseLong(uid);
		User u = LoginManager.getInstance().getUser(userID);
	%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%=HTMLEncoder.encode(u.getName()) %></title>
</head>

<link rel="stylesheet" href="LoginStyle.css" media="screen"
	type="text/css" />
<body>
	<div><a href="userList.jsp">Back</a></div>
	<div class="login-card" >
		<form method="post" action="profile.jsp?doctype=skulpt&id=<%=userID%>">
			<input type="submit" name="skulpt" class="login skulpt-submit"  value="View Skulpt Documents">
		</form>
		<form method="post" action="profile.jsp?doctype=plaintext&id=<%=userID%>">
			<input type="submit" name="text" class="login text-submit"  value="View Text Documents">
		</form>
		
		<form method="post" action="userModify.jsp?uid=<%=userID%>">
			<input type="text" name="username" value=<%=HTMLEncoder.encode(u.getName())%> required>
			<input type="submit" name="modifyU"class="login login-submit" value="Change Username">
			 
		</form>
		<form method="post" action="userModify.jsp?uid=<%=userID%>">
			
			<input
				type="password" name="pwd" placeholder="New Password" required> 
			<input type="password" name="rpwd" placeholder="Repeat Password" required>
			<input type="submit" name="modifyP"class="login login-submit"  value="Change Password">
			
		</form>
		<form method="post" action="userModify.jsp?uid=<%=userID%>">
			<input type="submit" name="delete"class="login delete-submit"  value="Delete User">
		</form>
	</div>		
</body>
</html>